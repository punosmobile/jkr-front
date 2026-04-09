import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/import_repository.dart';
import 'import_event.dart';
import 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportRepository repository;

  ImportBloc({required this.repository}) : super(const ImportState()) {
    on<ImportLoadFiles>(_onLoadFiles);
    on<ImportToggleFile>(_onToggleFile);
    on<ImportAnalyzeFiles>(_onAnalyzeFiles);
    on<ImportRemoveAnalyzedFile>(_onRemoveAnalyzedFile);
    on<ImportReorderFiles>(_onReorderFiles);
    on<ImportStartImport>(_onStartImport);
    on<ImportRunVelvoitetarkistus>(_onRunVelvoitetarkistus);
    on<ImportSetVelvoitteet>(_onSetVelvoitteet);
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
    emit(state.copyWith(isRunningVelvoite: true));
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
    emit(state.copyWith(isRunningVelvoite: true));
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
