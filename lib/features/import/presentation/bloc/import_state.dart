import '../../data/models/import_file.dart';
import '../../data/models/import_queue_item.dart';

enum ImportPageStatus { initial, loading, loaded, error }

enum ImportPhase { fileSelection, analysis, importing, completed }

class ImportState {
  final ImportPageStatus status;
  final ImportPhase phase;
  final List<ImportFile> sharepointFiles;
  final List<ImportFile> analyzedFiles;
  final List<ImportQueueItem> queueItems;
  final bool isAnalyzing;
  final bool isImporting;
  final bool isRunningVelvoite;
  final String? errorMessage;

  const ImportState({
    this.status = ImportPageStatus.initial,
    this.phase = ImportPhase.fileSelection,
    this.sharepointFiles = const [],
    this.analyzedFiles = const [],
    this.queueItems = const [],
    this.isAnalyzing = false,
    this.isImporting = false,
    this.isRunningVelvoite = false,
    this.errorMessage,
  });

  bool get hasAnalysisErrors =>
      analyzedFiles.any((f) => f.analysis?.hasError == true);

  bool get canStartImport =>
      analyzedFiles.isNotEmpty &&
      !hasAnalysisErrors &&
      !isImporting;

  int get selectedFileCount =>
      sharepointFiles.where((f) => f.selected).length;

  ImportState copyWith({
    ImportPageStatus? status,
    ImportPhase? phase,
    List<ImportFile>? sharepointFiles,
    List<ImportFile>? analyzedFiles,
    List<ImportQueueItem>? queueItems,
    bool? isAnalyzing,
    bool? isImporting,
    bool? isRunningVelvoite,
    String? errorMessage,
  }) {
    return ImportState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      sharepointFiles: sharepointFiles ?? this.sharepointFiles,
      analyzedFiles: analyzedFiles ?? this.analyzedFiles,
      queueItems: queueItems ?? this.queueItems,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isImporting: isImporting ?? this.isImporting,
      isRunningVelvoite: isRunningVelvoite ?? this.isRunningVelvoite,
      errorMessage: errorMessage,
    );
  }
}
