/// Application constants.
class AppConstants {
  const AppConstants._();
  
  static const String appName = 'jkrfront';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyLoggedOut = 'auth_logged_out';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyTrackedReportTaskId = 'tracked_report_task_id';
  static const String storageKeyTrackedReportTaskParams = 'tracked_report_task_params';
  static const String storageKeyTrackedReportTaskUi = 'tracked_report_task_ui';
  static const String storageKeyTrackedReportTaskStartedAt = 'tracked_report_task_started_at';
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}
