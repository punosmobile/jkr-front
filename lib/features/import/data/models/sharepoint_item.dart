/// Represents a file or folder item from SharePoint.
class SharepointItem {
  final String name;
  final String type; // 'folder' or 'file'
  final int? size;
  final String? lastModified;
  final int? childCount;

  const SharepointItem({
    required this.name,
    required this.type,
    this.size,
    this.lastModified,
    this.childCount,
  });

  bool get isFolder => type == 'folder';

  factory SharepointItem.fromJson(Map<String, dynamic> json) {
    return SharepointItem(
      name: json['name'] as String,
      type: json['type'] as String? ?? 'file',
      size: json['size'] as int?,
      lastModified: json['lastModified'] as String?,
      childCount: json['childCount'] as int?,
    );
  }
}

/// Result of pulling files from SharePoint to the backend server.
class SharepointPullResult {
  final List<SharepointDownloadedFile> downloaded;
  final List<SharepointPullError> errors;
  final String? targetDir;

  const SharepointPullResult({
    this.downloaded = const [],
    this.errors = const [],
    this.targetDir,
  });

  factory SharepointPullResult.fromJson(Map<String, dynamic> json) {
    return SharepointPullResult(
      downloaded: (json['downloaded'] as List<dynamic>?)
              ?.map((e) =>
                  SharepointDownloadedFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) =>
                  SharepointPullError.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      targetDir: json['target_dir'] as String?,
    );
  }
}

class SharepointDownloadedFile {
  final String filename;
  final int? size;
  final String? targetPath;

  const SharepointDownloadedFile({
    required this.filename,
    this.size,
    this.targetPath,
  });

  factory SharepointDownloadedFile.fromJson(Map<String, dynamic> json) {
    return SharepointDownloadedFile(
      filename: json['filename'] as String? ?? '',
      size: json['size'] as int?,
      targetPath: json['target_path'] as String?,
    );
  }
}

class SharepointPullError {
  final String path;
  final String error;

  const SharepointPullError({required this.path, required this.error});

  factory SharepointPullError.fromJson(Map<String, dynamic> json) {
    return SharepointPullError(
      path: json['path'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }
}

/// SharePoint integration status from backend.
class SharepointStatus {
  final bool configured;
  final String? siteId;
  final String? inputFolder;
  final String? outputFolder;

  const SharepointStatus({
    required this.configured,
    this.siteId,
    this.inputFolder,
    this.outputFolder,
  });

  factory SharepointStatus.fromJson(Map<String, dynamic> json) {
    return SharepointStatus(
      configured: json['configured'] as bool? ?? false,
      siteId: json['site_id'] as String?,
      inputFolder: json['input_folder'] as String?,
      outputFolder: json['output_folder'] as String?,
    );
  }
}
