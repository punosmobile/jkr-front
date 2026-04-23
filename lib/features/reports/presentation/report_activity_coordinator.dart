import 'package:flutter/foundation.dart';

// Lightweight banner payload shared with the global app shell.
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

// Singleton bridge between the reports feature and the global banner UI.
class ReportActivityCoordinator extends ChangeNotifier {
  ReportActivityCoordinator._();

  static final ReportActivityCoordinator instance =
      ReportActivityCoordinator._();

  ReportBannerSnapshot? _snapshot;

  ReportBannerSnapshot? get snapshot => _snapshot;

  // Publish the latest local banner state.
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

  // Clear the banner, optionally only for the matching task.
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