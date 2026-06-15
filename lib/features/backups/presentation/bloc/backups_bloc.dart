import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jkrfront/features/backups/data/repositories/backups_repository.dart';
import 'package:jkrfront/features/backups/data/web_file_helper.dart';
import 'package:jkrfront/features/backups/presentation/bloc/backups_event.dart';
import 'package:jkrfront/features/backups/presentation/bloc/backups_state.dart';

/// Hallinnoi varmuuskopioiden listausta, luontia, palautusta, poistoa,
/// latausta ja palvelimelle vientiä sekä pg_dump/pg_restore-tehtävien pollausta.
class BackupsBloc extends Bloc<BackupsEvent, BackupsState> {
  BackupsBloc({required BackupsRepository repository})
      : _repository = repository,
        super(const BackupsState()) {
    on<BackupsStarted>(_onStarted);
    on<BackupsRefreshed>(_onRefreshed);
    on<BackupsDumpRequested>(_onDumpRequested);
    on<BackupsRestoreRequested>(_onRestoreRequested);
    on<BackupsDeleteRequested>(_onDeleteRequested);
    on<BackupsDownloadRequested>(_onDownloadRequested);
    on<BackupsUploadRequested>(_onUploadRequested);
    on<BackupsOperationDismissed>(_onOperationDismissed);
    on<BackupsOperationPolled>(_onOperationPolled);
  }

  final BackupsRepository _repository;

  Timer? _pollTimer;
  int _feedbackSequence = 0;

  static const Duration _pollInterval = Duration(milliseconds: 1500);

  Future<void> _onStarted(
    BackupsStarted event,
    Emitter<BackupsState> emit,
  ) async {
    await _loadBackups(emit);
  }

  Future<void> _onRefreshed(
    BackupsRefreshed event,
    Emitter<BackupsState> emit,
  ) async {
    await _loadBackups(emit);
  }

  Future<void> _loadBackups(Emitter<BackupsState> emit) async {
    if (state.backups.isEmpty) {
      emit(state.copyWith(listStatus: BackupsListStatus.loading, listError: null));
    }
    try {
      final backups = await _repository.listBackups();
      emit(state.copyWith(
        listStatus: BackupsListStatus.loaded,
        backups: backups,
        listError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        listStatus: BackupsListStatus.error,
        listError: _message(e),
      ));
    }
  }

  Future<void> _onDumpRequested(
    BackupsDumpRequested event,
    Emitter<BackupsState> emit,
  ) async {
    if (state.isOperationActive) {
      return;
    }
    emit(state.copyWith(
      operation: const BackupOperation(
        kind: BackupOpKind.dump,
        status: BackupOpStatus.running,
        message: 'Käynnistetään varmuuskopiointia…',
      ),
    ));
    try {
      final taskId = await _repository.createDump();
      emit(state.copyWith(
        operation: state.operation?.copyWith(
          taskId: taskId,
          message: 'Varmuuskopiointi käynnissä…',
        ),
      ));
      _startPolling();
    } catch (e) {
      emit(state.copyWith(
        operation: BackupOperation(
          kind: BackupOpKind.dump,
          status: BackupOpStatus.failed,
          message: _message(e),
        ),
        feedback: _feedback(_message(e), isError: true),
      ));
    }
  }

  Future<void> _onRestoreRequested(
    BackupsRestoreRequested event,
    Emitter<BackupsState> emit,
  ) async {
    if (state.isOperationActive) {
      return;
    }
    emit(state.copyWith(
      operation: BackupOperation(
        kind: BackupOpKind.restore,
        status: BackupOpStatus.running,
        filename: event.filename,
        message: 'Käynnistetään palautusta…',
      ),
    ));
    try {
      final taskId = await _repository.restoreBackup(event.filename);
      emit(state.copyWith(
        operation: state.operation?.copyWith(
          taskId: taskId,
          message: 'Palautus käynnissä…',
        ),
      ));
      _startPolling();
    } catch (e) {
      emit(state.copyWith(
        operation: BackupOperation(
          kind: BackupOpKind.restore,
          status: BackupOpStatus.failed,
          filename: event.filename,
          message: _message(e),
        ),
        feedback: _feedback(_message(e), isError: true),
      ));
    }
  }

  Future<void> _onOperationPolled(
    BackupsOperationPolled event,
    Emitter<BackupsState> emit,
  ) async {
    final operation = state.operation;
    final taskId = operation?.taskId;
    if (operation == null || !operation.isRunning || taskId == null || taskId.isEmpty) {
      _stopPolling();
      return;
    }

    try {
      final snapshot = await _repository.fetchTask(taskId);
      if (!snapshot.isFinished) {
        emit(state.copyWith(
          operation: operation.copyWith(message: snapshot.message),
        ));
        return;
      }

      _stopPolling();
      final isDump = operation.kind == BackupOpKind.dump;

      // pg_restore palaa nollasta poikkeavalla koodilla, kun se ohittaa
      // objektitason virheitä (esim. --clean-pudotukset). Data on silti
      // palautettu: tunnistetaan tämä "errors ignored on restore" -rivistä ja
      // näytetään onnistumisena, jossa on varoitusten määrä.
      final ignoredErrors =
          !isDump && snapshot.isFailed ? _ignoredRestoreErrors(snapshot.combinedLog) : null;

      if (snapshot.isFailed && ignoredErrors == null) {
        final failMessage = snapshot.message ??
            (isDump ? 'Varmuuskopiointi epäonnistui' : 'Palautus epäonnistui');
        emit(state.copyWith(
          operation: operation.copyWith(
            status: BackupOpStatus.failed,
            message: failMessage,
          ),
          feedback: _feedback(failMessage, isError: true),
        ));
      } else {
        final String okMessage;
        if (isDump) {
          okMessage = 'Varmuuskopio luotu onnistuneesti';
        } else if (ignoredErrors != null && ignoredErrors > 0) {
          okMessage =
              'Tietokanta palautettu ($ignoredErrors varoitusta ohitettu – tämä on normaalia palautuksessa)';
        } else {
          okMessage = 'Tietokanta palautettu onnistuneesti';
        }
        emit(state.copyWith(
          operation: operation.copyWith(
            status: BackupOpStatus.completed,
            message: okMessage,
          ),
          feedback: _feedback(okMessage, isError: false),
        ));
      }
      // Lista on todennäköisesti muuttunut (uusi dump tai palautettu data).
      await _loadBackups(emit);
    } catch (_) {
      // Pollaus jatkuu seuraavalla tikillä.
    }
  }

  void _onOperationDismissed(
    BackupsOperationDismissed event,
    Emitter<BackupsState> emit,
  ) {
    if (state.isOperationActive) {
      return;
    }
    emit(state.copyWith(operation: null));
  }

  Future<void> _onDeleteRequested(
    BackupsDeleteRequested event,
    Emitter<BackupsState> emit,
  ) async {
    if (state.busyFilenames.contains(event.filename)) {
      return;
    }
    emit(state.copyWith(busyFilenames: {...state.busyFilenames, event.filename}));
    try {
      await _repository.deleteBackup(event.filename);
      final remaining = state.backups
          .where((backup) => backup.filename != event.filename)
          .toList();
      emit(state.copyWith(
        backups: remaining,
        busyFilenames: _without(event.filename),
        feedback: _feedback('Varmuuskopio poistettu', isError: false),
      ));
    } catch (e) {
      emit(state.copyWith(
        busyFilenames: _without(event.filename),
        feedback: _feedback(_message(e), isError: true),
      ));
    }
  }

  Future<void> _onDownloadRequested(
    BackupsDownloadRequested event,
    Emitter<BackupsState> emit,
  ) async {
    if (state.busyFilenames.contains(event.filename)) {
      return;
    }
    emit(state.copyWith(busyFilenames: {...state.busyFilenames, event.filename}));
    try {
      await _repository.downloadBackup(event.filename);
      emit(state.copyWith(
        busyFilenames: _without(event.filename),
        feedback: _feedback('Lataus aloitettu', isError: false),
      ));
    } catch (e) {
      emit(state.copyWith(
        busyFilenames: _without(event.filename),
        feedback: _feedback(_message(e), isError: true),
      ));
    }
  }

  Future<void> _onUploadRequested(
    BackupsUploadRequested event,
    Emitter<BackupsState> emit,
  ) async {
    if (state.isUploading) {
      return;
    }
    final PickedFile? picked;
    try {
      picked = await WebFileHelper.pickFile(accept: '.backup,.dump,.sql');
    } catch (e) {
      emit(state.copyWith(feedback: _feedback(_message(e), isError: true)));
      return;
    }
    if (picked == null) {
      return;
    }

    emit(state.copyWith(isUploading: true));
    try {
      await _repository.uploadBackup(picked);
      emit(state.copyWith(
        isUploading: false,
        feedback: _feedback('Varmuuskopio "${picked.name}" viety palvelimelle', isError: false),
      ));
      await _loadBackups(emit);
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        feedback: _feedback(_message(e), isError: true),
      ));
    }
  }

  /// Palauttaa pg_restoren ohittamien virheiden määrän, jos loki sisältää
  /// "errors ignored on restore: N" -rivin (data on tällöin palautettu).
  /// Palauttaa `null`, jos kyseessä on aito epäonnistuminen.
  int? _ignoredRestoreErrors(String log) {
    final match = RegExp(
      r'errors ignored on restore:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(log);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  Set<String> _without(String filename) {
    return state.busyFilenames.where((name) => name != filename).toSet();
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      add(const BackupsOperationPolled());
    });
    add(const BackupsOperationPolled());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  BackupFeedback _feedback(String message, {required bool isError}) {
    _feedbackSequence += 1;
    return BackupFeedback(id: _feedbackSequence, message: message, isError: isError);
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
