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

  /// Set of selected file names (not folders) in the current folder.
  final Set<String> selectedFiles;

  /// Whether a pull-to-server operation is in progress.
  final bool isPulling;

  /// Status message after a pull operation (e.g. "3 ladattu → /data/input").
  final String? pullStatusMessage;

  /// Whether the last pull had errors.
  final bool pullHadErrors;

  const SharepointState({
    this.status = SharepointPageStatus.initial,
    this.items = const [],
    this.currentFolder = '',
    this.folderHistory = const [],
    this.rootFolder,
    this.siteId,
    this.errorMessage,
    this.selectedFiles = const {},
    this.isPulling = false,
    this.pullStatusMessage,
    this.pullHadErrors = false,
  });

  SharepointState copyWith({
    SharepointPageStatus? status,
    List<SharepointItem>? items,
    String? currentFolder,
    List<String>? folderHistory,
    String? rootFolder,
    String? siteId,
    String? errorMessage,
    Set<String>? selectedFiles,
    bool? isPulling,
    String? pullStatusMessage,
    bool? pullHadErrors,
  }) {
    return SharepointState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentFolder: currentFolder ?? this.currentFolder,
      folderHistory: folderHistory ?? this.folderHistory,
      rootFolder: rootFolder ?? this.rootFolder,
      siteId: siteId ?? this.siteId,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      isPulling: isPulling ?? this.isPulling,
      pullStatusMessage: pullStatusMessage,
      pullHadErrors: pullHadErrors ?? this.pullHadErrors,
    );
  }

  /// Breadcrumb segments from the root folder.
  List<String> get breadcrumbs {
    if (currentFolder.isEmpty) return [];
    return currentFolder.split('/').where((s) => s.isNotEmpty).toList();
  }

  int get fileCount => items.where((i) => !i.isFolder).length;
  int get folderCount => items.where((i) => i.isFolder).length;
  int get selectedCount => selectedFiles.length;
  bool get allFilesSelected =>
      fileCount > 0 && selectedFiles.length == fileCount;

  /// Build full SharePoint paths for selected files.
  List<String> get selectedFilePaths {
    return selectedFiles.map((name) {
      return currentFolder.isEmpty ? name : '$currentFolder/$name';
    }).toList();
  }
}
