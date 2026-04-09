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
