import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/import_queue_item.dart';
import '../../data/repositories/import_repository.dart';
import 'import_event.dart';
import 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportRepository repository;
  final Duration refreshRetryDelay;

  ImportBloc({
    required this.repository,
    this.refreshRetryDelay = const Duration(seconds: 2),
  }) : super(const ImportState()) {
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

    // Ids of successfully imported files (= SharePoint item id).
    final importedIds = <String>{};

    if (!event.isActive && pendingItems.isNotEmpty) {
      final taskIds = pendingItems
          .map((i) => i.taskId!)
          .toSet();

      final updatedItems = List<ImportQueueItem>.from(state.queueItems);
      for (final taskId in taskIds) {
        try {
          final result = await repository.fetchTaskStatus(taskId);
          if (result.isFinished) {
            final failedFile = result.hasError
                ? _failedFileName(
                    result.output,
                    updatedItems
                        .where((i) => i.taskId == taskId)
                        .map((i) => i.fileName),
                  )
                : null;
            for (int i = 0; i < updatedItems.length; i++) {
              if (updatedItems[i].taskId == taskId) {
                final showError = failedFile == null ||
                    failedFile == updatedItems[i].fileName;
                updatedItems[i] = updatedItems[i].copyWith(
                  status: result.hasError
                      ? ImportQueueStatus.error
                      : ImportQueueStatus.completed,
                  errorOutput: showError ? result.errorOutput : null,
                );
                if (!result.hasError) importedIds.add(updatedItems[i].id);
              }
            }
          }
        } catch (_) {}
      }
      emit(state.copyWith(
        queueItems: updatedItems,
        // Drop imported files from the pre-analysis so the same import can't be
        // started again. Failed files stay visible.
        analyzedFiles: state.analyzedFiles
            .where((f) => !importedIds.contains(f.id))
            .toList(),
      ));
    }

    // Refresh the SharePoint list when our own import finished (importedIds) or
    // any import ended (running -> done). After a successful import the source
    // files are moved JKR-input -> viedyt, so they must not stay in the
    // "Saatavilla Sharepointissa" list.
    if (importedIds.isNotEmpty || (wasImporting && !event.isActive)) {
      await _refreshSharepointFiles(emit, untilGone: importedIds);
    }
  }

  // ponytail: infers the failing file from the log (last file mentioned before
  // the first [ERROR] line). Replace once the backend returns per-file status.
  static String? _failedFileName(String output, Iterable<String> fileNames) {
    final lines = output.split('\n');
    final firstError = lines.indexWhere((l) => l.contains('[ERROR]'));
    if (firstError < 0) return null;
    for (final line in lines.take(firstError).toList().reversed) {
      for (final name in fileNames) {
        if (line.contains('/$name') || line.contains(' $name')) return name;
      }
    }
    return null;
  }

  // ponytail: the backend marks the task done before moving files to viedyt,
  // so refetch until the imported files are gone from the list (max ~8 s).
  // Remove the loop once the backend sets the status only after archiving.
  Future<void> _refreshSharepointFiles(
    Emitter<ImportState> emit, {
    required Set<String> untilGone,
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      if (attempt > 0) await Future.delayed(refreshRetryDelay);
      try {
        final files = await repository.fetchSharepointFiles();
        emit(state.copyWith(sharepointFiles: files));
        if (!files.any((f) => untilGone.contains(f.id))) return;
      } catch (_) {
        // The list refreshes on the next load.
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
