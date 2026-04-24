import '../../../../core/tasks/app_task_type.dart';

// Backend task statuses used by the reports feature.
enum ReportTaskStatus {
  pending,
  running,
  completed,
  failed;

  static ReportTaskStatus fromJson(String value) {
    return ReportTaskStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ReportTaskStatus.failed,
    );
  }
}

// Response returned when a new report task is started.
class ReportTaskResponse {
  const ReportTaskResponse({
    required this.taskId,
    required this.status,
    required this.taskType,
    required this.description,
    required this.message,
  });

  final String taskId;
  final ReportTaskStatus status;
  final AppTaskType taskType;
  final String description;
  final String message;

  factory ReportTaskResponse.fromJson(Map<String, dynamic> json) {
    return ReportTaskResponse(
      taskId: json['task_id'] as String? ?? '',
      status: ReportTaskStatus.fromJson(json['status'] as String? ?? 'failed'),
      taskType: AppTaskType.fromApiValue(
        (json['taskType'] ?? json['task_type']) as String?,
      ),
      description: json['description'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}