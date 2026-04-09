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

  static int _compareItems(a, b) {
    // Folders first
    if (a.isFolder && !b.isFolder) return -1;
    if (!a.isFolder && b.isFolder) return 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
