/// Represents a file available for import (e.g. from Sharepoint).
enum ImportFileBadge { uusi, paivitys, tarkista }

enum AnalysisStatus { pending, analyzed, error }

enum ImportAnalysisErrorCode { notRunnable, missingResult }

class ImportFile {

  factory ImportFile.fromJson(Map<String, dynamic> json) {
    return ImportFile(
      id: json['id'] as String,
      type: json['type'] as String,
      fileType: json['fileType'] as String?,
      name: json['name'] as String,
      path: json['path'] as String? ?? '',
      pathOnServer: json['target_path'] as String?,
      size: (json['size'] as int) >= 1000000
          ? '${((json['size'] as int) / 1000000).toStringAsFixed(1)} MB'
          : '${((json['size'] as int) / 1000).toStringAsFixed(1)} kB',
      webUrl: json['webUrl'] as String,
      lastModified: json['lastModified'] as String,
      badge: json['badge'] != null ? json['badge'] as ImportFileBadge : ImportFileBadge.uusi
    );
  }

  const ImportFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.webUrl,
    required this.badge,
    required this.path,
    this.fileType = '',
    this.pathOnServer,
    this.lastModified = '',
    this.selected = false,
    this.analysisStatus = AnalysisStatus.pending,
    this.analysis,
    
  });

  final String id;
  final String name;
  final String path;
  final String? pathOnServer;
  final String size;
  final String type;
  final String? fileType;
  final String webUrl;
  final String lastModified;
  final ImportFileBadge badge;
  final bool selected;
  final AnalysisStatus analysisStatus;
  final ImportAnalysis? analysis;
  

  ImportFile copyWith({
    String? id,
    String? name,
    String? path,
    String? pathOnServer,
    String? size,
    String? type,
    String? fileType,
    ImportFileBadge? badge,
    String? webUrl,
    String? lastModified,
    bool? selected,
    AnalysisStatus? analysisStatus,
    ImportAnalysis? analysis,
  }) {
    return ImportFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      pathOnServer: pathOnServer ?? this.pathOnServer,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      type: type ?? this.type,
      webUrl: webUrl ?? this.webUrl,
      lastModified: lastModified ?? this.lastModified,
      badge: badge ?? this.badge,
      selected: selected ?? this.selected,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysis: analysis ?? this.analysis,
    );
  }
}

/// Result of pre-analysis for a single file.
class ImportAnalysis {
  const ImportAnalysis({
    required this.rowCount,
    this.newCount = 0,
    this.updateCount = 0,
    this.unmatchedCount = 0,
    this.errorCode,
    this.errorMessage,
  });

  final int rowCount;
  final int newCount;
  final int updateCount;
  final int unmatchedCount;
  final ImportAnalysisErrorCode? errorCode;
  final String? errorMessage;

  bool get hasError => errorCode != null || (errorMessage?.isNotEmpty ?? false);
}
