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

class ReportTaskResponse {
  const ReportTaskResponse({
    required this.taskId,
    required this.status,
    required this.description,
    required this.message,
  });

  final String taskId;
  final ReportTaskStatus status;
  final String description;
  final String message;

  factory ReportTaskResponse.fromJson(Map<String, dynamic> json) {
    return ReportTaskResponse(
      taskId: json['task_id'] as String? ?? '',
      status: ReportTaskStatus.fromJson(json['status'] as String? ?? 'failed'),
      description: json['description'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}