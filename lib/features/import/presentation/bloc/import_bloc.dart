import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/import_queue_item.dart';
import '../../data/repositories/import_repository.dart';
import 'import_event.dart';
import 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportRepository repository;

  ImportBloc({required this.repository}) : super(const ImportState()) {
    on<ImportLoadFiles>(_onLoadFiles);
    on<ImportToggleFile>(_onToggleFile);
    on<ImportSetAllSelected>(_onSetAllSelected);
    on<ImportAnalyzeFiles>(_onAnalyzeFiles);
    on<ImportRemoveAnalyzedFile>(_onRemoveAnalyzedFile);
    on<ImportReorderFiles>(_onReorderFiles);
    on<ImportStartImport>(_onStartImport);
    on<ImportRunVelvoitetarkistus>(_onRunVelvoitetarkistus);
    on<ImportSetVelvoitteet>(_onSetVelvoitteet);
    on<ImportTaskStatusChanged>(_onTaskStatusChanged);
  }

  Future<void> _onTaskStatusChanged(
    ImportTaskStatusChanged event,
    Emitter<ImportState> emit,
  ) async {
    // Edellinen tila ennen päivitystä, jotta tunnistetaan siirtymä
    // "käynnissä -> valmis" (eikä reagoida joka pollaukseen).
    final wasImporting = state.isImporting;
    emit(state.copyWith(isImporting: event.isActive));

    final pendingItems = state.queueItems.where((i) =>
        i.taskId != null &&
        i.status != ImportQueueStatus.completed &&
        i.status != ImportQueueStatus.error);

    if (!event.isActive && pendingItems.isNotEmpty) {
      final taskIds = pendingItems
          .map((i) => i.taskId!)
          .toSet();

      final updatedItems = List<ImportQueueItem>.from(state.queueItems);
      for (final taskId in taskIds) {
        try {
          final result = await repository.fetchTaskStatus(taskId);
          if (result.isFinished) {
            for (int i = 0; i < updatedItems.length; i++) {
              if (updatedItems[i].taskId == taskId) {
                updatedItems[i] = updatedItems[i].copyWith(
                  status: result.hasError
                      ? ImportQueueStatus.error
                      : ImportQueueStatus.completed,
                  errorOutput: result.errorOutput,
                );
              }
            }
          }
        } catch (_) {}
      }
      emit(state.copyWith(queueItems: updatedItems));
    }

    // Kun tuonti on juuri päättynyt (käynnissä -> valmis), päivitä
    // SharePoint-tiedostolista: onnistuneen tuonnin jälkeen lähdetiedostot on
    // arkistoitu (siirretty JKR-input -> viedyt), joten ne eivät saa jäädä
    // näkymään "Saatavilla Sharepointissa" -listaan. Suoritetaan vain
    // siirtymähetkellä, ei joka pollauksella.
    if (wasImporting && !event.isActive) {
      try {
        final files = await repository.fetchSharepointFiles();
        emit(state.copyWith(sharepointFiles: files));
      } catch (_) {
        // Lista päivittyy seuraavalla manuaalisella latauksella.
      }
    }
  }

  Future<void> _onLoadFiles(
    ImportLoadFiles event,
    Emitter<ImportState> emit,
  ) async {
    emit(state.copyWith(status: ImportPageStatus.loading));
    try {
      final files = await repository.fetchSharepointFiles();

      emit(state.copyWith(
        status: ImportPageStatus.loaded,
        sharepointFiles: files,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImportPageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSetAllSelected(
    ImportSetAllSelected event,
    Emitter<ImportState> emit,
  ) {
    final updated = state.sharepointFiles
        .map((f) => f.copyWith(selected: event.selected))
        .toList();
    emit(state.copyWith(sharepointFiles: updated));
  }

  void _onToggleFile(
    ImportToggleFile event,
    Emitter<ImportState> emit,
  ) {
    final updated = state.sharepointFiles.map((f) {
      if (f.id == event.fileId) {
        return f.copyWith(selected: !f.selected);
      }
      return f;
    }).toList();
    emit(state.copyWith(sharepointFiles: updated));
  }

  Future<void> _onAnalyzeFiles(
    ImportAnalyzeFiles event,
    Emitter<ImportState> emit,
  ) async {
    final selected = state.sharepointFiles.where((f) => f.selected).toList();
    if (selected.isEmpty) return;

    emit(state.copyWith(isAnalyzing: true));
    try {
      final analyzed = await repository.analyzeFiles(selected);
      emit(state.copyWith(
        isAnalyzing: false,
        analyzedFiles: analyzed,
        phase: ImportPhase.analysis,
      ));
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveAnalyzedFile(
    ImportRemoveAnalyzedFile event,
    Emitter<ImportState> emit,
  ) {
    final updated =
        state.analyzedFiles.where((f) => f.id != event.fileId).toList();
    emit(state.copyWith(analyzedFiles: updated));
  }

  void _onReorderFiles(
    ImportReorderFiles event,
    Emitter<ImportState> emit,
  ) {
    final files = List.of(state.analyzedFiles);
    var newIndex = event.newIndex;
    if (newIndex > event.oldIndex) newIndex--;
    final item = files.removeAt(event.oldIndex);
    files.insert(newIndex, item);
    emit(state.copyWith(analyzedFiles: files));
  }

  Future<void> _onStartImport(
    ImportStartImport event,
    Emitter<ImportState> emit,
  ) async {
    emit(state.copyWith(isImporting: true, phase: ImportPhase.importing));
    try {
      final queueItems = await repository.startImport(state.analyzedFiles);
      emit(state.copyWith(
        queueItems: queueItems,
      ));
      // TODO: Listen to WebSocket for real-time progress updates
    } catch (e) {
      emit(state.copyWith(
        isImporting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRunVelvoitetarkistus(
    ImportRunVelvoitetarkistus event,
    Emitter<ImportState> emit,
  ) async {
    emit(state.copyWith(isRunningVelvoite: true, isImporting: true));
    try {
      await repository.runVelvoitetarkistus(event.date);
      emit(state.copyWith(isRunningVelvoite: false));
    } catch (e) {
      emit(state.copyWith(
        isRunningVelvoite: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetVelvoitteet(
    ImportSetVelvoitteet event,
    Emitter<ImportState> emit,
  ) async {
    emit(state.copyWith(isRunningVelvoite: true, isImporting: true));
    try {
      await repository.setVelvoitteet();
      emit(state.copyWith(isRunningVelvoite: false));
    } catch (e) {
      emit(state.copyWith(
        isRunningVelvoite: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
