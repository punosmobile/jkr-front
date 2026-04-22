// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'jkrfront';

  @override
  String get welcome => 'Welcome';

  @override
  String get home => 'Home';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get sidebarOrgName => 'Lahti region\nwaste management authority';

  @override
  String get sidebarAppName => 'JKR Data Management';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navImport => 'Data import';

  @override
  String get navSharepoint => 'SharePoint';

  @override
  String get navRealtimeLog => 'Real-time log';

  @override
  String get navReports => 'Reports';

  @override
  String get navBackups => 'Backups';

  @override
  String get navDbDocs => 'Database docs';

  @override
  String get navHelp => 'Help & support';

  @override
  String get navPlannedFeatures => 'Planned features';

  @override
  String get navTargets => 'Targets';

  @override
  String get navMap => 'Map view';

  @override
  String get navDatabase => 'Database';

  @override
  String get navLogs => 'Logs & history';

  @override
  String get dbConnectionOk => 'DB connection OK';

  @override
  String get dbNoConnection => 'No connection';

  @override
  String get logout => 'Log out';

  @override
  String get loginBrandBadge => 'Lahti JKR';

  @override
  String get loginCompactDescription => 'The Lahti Waste Management Register brings data entry, monitoring, and reporting into one view.';

  @override
  String get loginBrandTitle => 'Lahti Waste Management\nRegister';

  @override
  String get loginBrandDescription => 'A unified interface for data entry, documentation, and daily follow-up. Sign in with your Microsoft account.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginDescription => 'Use your organization\'s Microsoft account.';

  @override
  String get loginEnvironmentDevelopment => 'Development';

  @override
  String get loginEnvironmentTest => 'Test';

  @override
  String get loginEnvironmentProduction => 'Production';

  @override
  String get loginButton => 'Continue with Microsoft';

  @override
  String get loginButtonLoading => 'Signing in...';

  @override
  String get loginBrowserHint => 'Your browser opens Microsoft sign-in and returns you to this application.';

  @override
  String get loginErrorFailed => 'Sign-in failed. Please try again.';

  @override
  String get loginErrorGeneric => 'Sign-in could not be completed right now.';
}
