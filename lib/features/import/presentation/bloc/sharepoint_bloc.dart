import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sharepoint_item.dart';
import '../../data/repositories/sharepoint_repository.dart';
import 'sharepoint_event.dart';
import 'sharepoint_state.dart';

class SharepointBloc extends Bloc<SharepointEvent, SharepointState> {
  final SharepointRepository _repository;

  SharepointBloc({required SharepointRepository repository})
      : _repository = repository,
        super(const SharepointState()) {
    on<SharepointInitRequested>(_onInit);
    on<SharepointFolderOpened>(_onFolderOpened);
    on<SharepointNavigatedBack>(_onNavigatedBack);
    on<SharepointRefreshRequested>(_onRefresh);
    on<SharepointFileToggled>(_onFileToggled);
    on<SharepointAllFilesToggled>(_onAllFilesToggled);
    on<SharepointPullOneRequested>(_onPullOne);
    on<SharepointPullSelectedRequested>(_onPullSelected);
  }

  Future<void> _onInit(
    SharepointInitRequested event,
    Emitter<SharepointState> emit,
  ) async {
    emit(state.copyWith(status: SharepointPageStatus.loading));
    try {
      final status = await _repository.fetchStatus();
      if (!status.configured) {
        emit(state.copyWith(status: SharepointPageStatus.notConfigured));
        return;
      }
      final rootFolder = status.inputFolder ?? '';
      final items = await _repository.fetchFiles(folder: rootFolder);
      // Sort: folders first, then alphabetically
      items.sort(_compareItems);
      emit(state.copyWith(
        status: SharepointPageStatus.loaded,
        items: items,
        currentFolder: rootFolder,
        rootFolder: rootFolder,
        siteId: status.siteId,
        folderHistory: const [],
        selectedFiles: const {},
        pullStatusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SharepointPageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFolderOpened(
    SharepointFolderOpened event,
    Emitter<SharepointState> emit,
  ) async {
    emit(state.copyWith(status: SharepointPageStatus.loading));
    try {
      final items = await _repository.fetchFiles(folder: event.folder);
      items.sort(_compareItems);
      emit(state.copyWith(
        status: SharepointPageStatus.loaded,
        items: items,
        currentFolder: event.folder,
        folderHistory: [...state.folderHistory, state.currentFolder],
        selectedFiles: const {},
        pullStatusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SharepointPageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onNavigatedBack(
    SharepointNavigatedBack event,
    Emitter<SharepointState> emit,
  ) async {
    if (state.folderHistory.isEmpty) return;
    final previousFolder = state.folderHistory.last;
    final newHistory = List<String>.from(state.folderHistory)..removeLast();
    emit(state.copyWith(status: SharepointPageStatus.loading));
    try {
      final items = await _repository.fetchFiles(folder: previousFolder);
      items.sort(_compareItems);
      emit(state.copyWith(
        status: SharepointPageStatus.loaded,
        items: items,
        currentFolder: previousFolder,
        folderHistory: newHistory,
        selectedFiles: const {},
        pullStatusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SharepointPageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
    SharepointRefreshRequested event,
    Emitter<SharepointState> emit,
  ) async {
    emit(state.copyWith(status: SharepointPageStatus.loading));
    try {
      final items = await _repository.fetchFiles(folder: state.currentFolder);
      items.sort(_compareItems);
      emit(state.copyWith(
        status: SharepointPageStatus.loaded,
        items: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SharepointPageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFileToggled(
    SharepointFileToggled event,
    Emitter<SharepointState> emit,
  ) {
    final updated = Set<String>.from(state.selectedFiles);
    if (updated.contains(event.fileName)) {
      updated.remove(event.fileName);
    } else {
      updated.add(event.fileName);
    }
    emit(state.copyWith(selectedFiles: updated));
  }

  void _onAllFilesToggled(
    SharepointAllFilesToggled event,
    Emitter<SharepointState> emit,
  ) {
    if (event.selected) {
      final allFileNames = state.items
          .where((i) => !i.isFolder)
          .map((i) => i.name)
          .toSet();
      emit(state.copyWith(selectedFiles: allFileNames));
    } else {
      emit(state.copyWith(selectedFiles: const {}));
    }
  }

  Future<void> _onPullOne(
    SharepointPullOneRequested event,
    Emitter<SharepointState> emit,
  ) async {
    await _runPullTask(
      emit,
      paths: [event.filePath],
      successMessage: '${event.filePath.split('/').last} ladattu palvelimelle',
    );
  }

  Future<void> _onPullSelected(
    SharepointPullSelectedRequested event,
    Emitter<SharepointState> emit,
  ) async {
    final paths = state.selectedFilePaths;
    if (paths.isEmpty) return;
    await _runPullTask(
      emit,
      paths: paths,
      successMessage: '${paths.length} tiedoston lataus valmistui',
      clearSelectionOnSuccess: true,
    );
  }

  Future<void> _runPullTask(
    Emitter<SharepointState> emit, {
    required List<String> paths,
    required String successMessage,
    bool clearSelectionOnSuccess = false,
  }) async {
    emit(state.copyWith(isPulling: true, pullStatusMessage: null, pullHadErrors: false));
    try {
      final task = await _repository.pullToServer(paths: paths);
      emit(state.copyWith(
        isPulling: true,
        pullStatusMessage: 'Lataus käynnistetty (tehtävä ${task.taskId})...',
        pullHadErrors: false,
      ));

      while (!isClosed) {
        final result = await _repository.fetchTaskStatus(task.taskId);
        if (result.isFinished) {
          emit(state.copyWith(
            isPulling: false,
            pullStatusMessage: result.hasError
                ? 'Lataus epäonnistui: ${result.errorOutput ?? 'tuntematon virhe'}'
                : successMessage,
            pullHadErrors: result.hasError,
            selectedFiles: clearSelectionOnSuccess ? const {} : state.selectedFiles,
          ));
          return;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      emit(state.copyWith(
        isPulling: false,
        pullStatusMessage: 'Virhe: $e',
        pullHadErrors: true,
      ));
    }
  }

  static int _compareItems(SharepointItem a, SharepointItem b) {
    // Folders first
    if (a.isFolder && !b.isFolder) return -1;
    if (!a.isFolder && b.isFolder) return 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
