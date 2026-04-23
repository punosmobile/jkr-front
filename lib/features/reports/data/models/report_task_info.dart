import '../../../../core/tasks/app_task_type.dart';
import 'report_task_response.dart';

// File metadata attached to a completed report task.
class ReportTaskFile {
  const ReportTaskFile({
    this.filename,
    this.localPath,
    this.size,
    this.sharepointUrl,
    this.sharepointError,
  });

  final String? filename;
  final String? localPath;
  final int? size;
  final String? sharepointUrl;
  final String? sharepointError;

  factory ReportTaskFile.fromJson(Map<String, dynamic> json) {
    return ReportTaskFile(
      filename: json['filename'] as String?,
      localPath: json['local_path'] as String?,
      size: (json['size'] as num?)?.toInt(),
      sharepointUrl: json['sharepoint_url'] as String?,
      sharepointError: json['sharepoint_error'] as String?,
    );
  }
}

// Backend task payload enriched with helpers used by the reports UI.
class ReportTaskInfo {
  const ReportTaskInfo({
    required this.id,
    required this.status,
    required this.taskType,
    required this.runner,
    required this.command,
    required this.description,
    required this.output,
    required this.error,
    this.resultFile,
  });

  final String id;
  final ReportTaskStatus status;
  final AppTaskType taskType;
  final String runner;
  final String command;
  final String description;
  final String output;
  final String error;
  final ReportTaskFile? resultFile;

  ReportTaskInfo copyWith({
    String? id,
    ReportTaskStatus? status,
    AppTaskType? taskType,
    String? runner,
    String? command,
    String? description,
    String? output,
    String? error,
    ReportTaskFile? resultFile,
  }) {
    return ReportTaskInfo(
      id: id ?? this.id,
      status: status ?? this.status,
      taskType: taskType ?? this.taskType,
      runner: runner ?? this.runner,
      command: command ?? this.command,
      description: description ?? this.description,
      output: output ?? this.output,
      error: error ?? this.error,
      resultFile: resultFile ?? this.resultFile,
    );
  }

  factory ReportTaskInfo.fromJson(Map<String, dynamic> json) {
    final resultFileJson = json['result_file'];

    return ReportTaskInfo(
      id: json['id'] as String? ?? '',
      status: ReportTaskStatus.fromJson(json['status'] as String? ?? 'failed'),
      taskType: AppTaskType.fromApiValue(
        (json['taskType'] ?? json['task_type']) as String?,
        command: json['command'] as String? ?? '',
        description: json['description'] as String? ?? '',
      ),
      runner: json['runner'] as String? ?? '',
      command: json['command'] as String? ?? '',
      description: json['description'] as String? ?? '',
      output: json['output'] as String? ?? '',
      error: json['error'] as String? ?? '',
      resultFile: resultFileJson is Map
          ? ReportTaskFile.fromJson(Map<String, dynamic>.from(resultFileJson))
          : null,
    );
  }

  String? get latestOutputLine => _lastNonEmptyLine(output);

  String? get latestErrorLine => _lastNonEmptyLine(error);

  bool get isActive =>
      status == ReportTaskStatus.pending || status == ReportTaskStatus.running;

  bool get isReportTask => taskType.isReport;

  // Use the most recent non-empty line from task output/error streams.
  static String? _lastNonEmptyLine(String source) {
    final lines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return null;
    }
    return lines.last;
  }
}