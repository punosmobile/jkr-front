import 'package:flutter_bloc/flutter_bloc.dart';

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
    emit(state.copyWith(isPulling: true, pullStatusMessage: null, pullHadErrors: false));
    try {
      final result = await _repository.pullToServer(paths: [event.filePath]);
      final ok = result.downloaded.length;
      final fail = result.errors.length;
      String msg;
      if (ok > 0) {
        final dl = result.downloaded.first;
        msg = '${dl.filename} ladattu → ${result.targetDir ?? dl.targetPath ?? ''}';
      } else {
        msg = 'Lataus epäonnistui';
      }
      if (fail > 0) {
        msg += ' (${fail} virhe${fail > 1 ? 'ttä' : ''})';
      }
      emit(state.copyWith(
        isPulling: false,
        pullStatusMessage: msg,
        pullHadErrors: fail > 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        isPulling: false,
        pullStatusMessage: 'Virhe: $e',
        pullHadErrors: true,
      ));
    }
  }

  Future<void> _onPullSelected(
    SharepointPullSelectedRequested event,
    Emitter<SharepointState> emit,
  ) async {
    final paths = state.selectedFilePaths;
    if (paths.isEmpty) return;
    emit(state.copyWith(isPulling: true, pullStatusMessage: null, pullHadErrors: false));
    try {
      final result = await _repository.pullToServer(paths: paths);
      final ok = result.downloaded.length;
      final fail = result.errors.length;
      String msg = '$ok ladattu';
      if (fail > 0) msg += ', $fail epäonnistui';
      msg += ' → ${result.targetDir ?? ''}';
      emit(state.copyWith(
        isPulling: false,
        pullStatusMessage: msg,
        pullHadErrors: fail > 0,
        selectedFiles: const {},
      ));
    } catch (e) {
      emit(state.copyWith(
        isPulling: false,
        pullStatusMessage: 'Virhe: $e',
        pullHadErrors: true,
      ));
    }
  }

  static int _compareItems(a, b) {
    // Folders first
    if (a.isFolder && !b.isFolder) return -1;
    if (!a.isFolder && b.isFolder) return 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
