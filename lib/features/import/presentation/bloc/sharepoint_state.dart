import '../../data/models/sharepoint_item.dart';

enum SharepointPageStatus {
  initial,
  loading,
  loaded,
  error,
  notConfigured,
}

class SharepointState {
  final SharepointPageStatus status;
  final List<SharepointItem> items;
  final String currentFolder;
  final List<String> folderHistory;
  final String? rootFolder;
  final String? siteId;
  final String? errorMessage;

  const SharepointState({
    this.status = SharepointPageStatus.initial,
    this.items = const [],
    this.currentFolder = '',
    this.folderHistory = const [],
    this.rootFolder,
    this.siteId,
    this.errorMessage,
  });

  SharepointState copyWith({
    SharepointPageStatus? status,
    List<SharepointItem>? items,
    String? currentFolder,
    List<String>? folderHistory,
    String? rootFolder,
    String? siteId,
    String? errorMessage,
  }) {
    return SharepointState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentFolder: currentFolder ?? this.currentFolder,
      folderHistory: folderHistory ?? this.folderHistory,
      rootFolder: rootFolder ?? this.rootFolder,
      siteId: siteId ?? this.siteId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Breadcrumb segments from the root folder.
  List<String> get breadcrumbs {
    if (currentFolder.isEmpty) return [];
    return currentFolder.split('/').where((s) => s.isNotEmpty).toList();
  }

  int get fileCount => items.where((i) => !i.isFolder).length;
  int get folderCount => items.where((i) => i.isFolder).length;
}
