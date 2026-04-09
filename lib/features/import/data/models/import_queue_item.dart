/// Represents an item in the import execution queue.
enum ImportQueueStatus { waiting, running, completed, error }

class ImportQueueItem {
  final String id;
  final String fileName;
  final ImportQueueStatus status;
  final double progress;
  final int processedCount;
  final int totalCount;
  final String? estimatedTime;
  final List<String> logLines;

  const ImportQueueItem({
    required this.id,
    required this.fileName,
    this.status = ImportQueueStatus.waiting,
    this.progress = 0,
    this.processedCount = 0,
    this.totalCount = 0,
    this.estimatedTime,
    this.logLines = const [],
  });

  ImportQueueItem copyWith({
    String? id,
    String? fileName,
    ImportQueueStatus? status,
    double? progress,
    int? processedCount,
    int? totalCount,
    String? estimatedTime,
    List<String>? logLines,
  }) {
    return ImportQueueItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      processedCount: processedCount ?? this.processedCount,
      totalCount: totalCount ?? this.totalCount,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      logLines: logLines ?? this.logLines,
    );
  }
}
