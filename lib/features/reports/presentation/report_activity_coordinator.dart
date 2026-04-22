import 'package:flutter/foundation.dart';

class ReportBannerSnapshot {
  const ReportBannerSnapshot({
    required this.title,
    this.status,
    this.taskId,
  });

  final String title;
  final String? status;
  final String? taskId;
}

class ReportActivityCoordinator extends ChangeNotifier {
  ReportActivityCoordinator._();

  static final ReportActivityCoordinator instance =
      ReportActivityCoordinator._();

  ReportBannerSnapshot? _snapshot;

  ReportBannerSnapshot? get snapshot => _snapshot;

  void show({
    required String title,
    String? status,
    String? taskId,
  }) {
    _snapshot = ReportBannerSnapshot(
      title: title,
      status: status,
      taskId: taskId,
    );
    notifyListeners();
  }

  void clear({String? taskId}) {
    if (_snapshot == null) {
      return;
    }
    if (taskId != null && _snapshot!.taskId != taskId) {
      return;
    }
    _snapshot = null;
    notifyListeners();
  }
}