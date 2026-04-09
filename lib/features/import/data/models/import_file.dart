/// Represents a file available for import (e.g. from Sharepoint).
enum ImportFileBadge { uusi, paivitys, tarkista }

enum AnalysisStatus { pending, analyzed, error }

class ImportFile {
  final String id;
  final String name;
  final String size;
  final ImportFileBadge badge;
  final bool selected;
  final AnalysisStatus analysisStatus;
  final ImportAnalysis? analysis;

  const ImportFile({
    required this.id,
    required this.name,
    required this.size,
    required this.badge,
    this.selected = false,
    this.analysisStatus = AnalysisStatus.pending,
    this.analysis,
  });

  ImportFile copyWith({
    String? id,
    String? name,
    String? size,
    ImportFileBadge? badge,
    bool? selected,
    AnalysisStatus? analysisStatus,
    ImportAnalysis? analysis,
  }) {
    return ImportFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      badge: badge ?? this.badge,
      selected: selected ?? this.selected,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysis: analysis ?? this.analysis,
    );
  }
}

/// Result of pre-analysis for a single file.
class ImportAnalysis {
  final int rowCount;
  final int newCount;
  final int updateCount;
  final int unmatchedCount;
  final String? errorMessage;

  const ImportAnalysis({
    required this.rowCount,
    this.newCount = 0,
    this.updateCount = 0,
    this.unmatchedCount = 0,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
}
