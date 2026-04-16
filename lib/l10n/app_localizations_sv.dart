// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'jkrfront';

  @override
  String get welcome => 'Välkommen';

  @override
  String get home => 'Hem';

  @override
  String get loading => 'Laddar...';

  @override
  String get error => 'Fel';

  @override
  String get retry => 'Försök igen';

  @override
  String get sidebarOrgName => 'Lahtisregionens\navfallsmyndighet';

  @override
  String get sidebarAppName => 'JKR Datahantering';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navImport => 'Dataimport';

  @override
  String get navSharepoint => 'SharePoint';

  @override
  String get navRealtimeLog => 'Realtidslogg';

  @override
  String get navReports => 'Rapporter';

  @override
  String get navBackups => 'Säkerhetskopior';

  @override
  String get navDbDocs => 'Databasdok.';

  @override
  String get navHelp => 'Hjälp & support';

  @override
  String get navPlannedFeatures => 'Planerade funktioner';

  @override
  String get navTargets => 'Objekt';

  @override
  String get navMap => 'Kartvy';

  @override
  String get navDatabase => 'Databas';

  @override
  String get navLogs => 'Loggar & historik';

  @override
  String get dbConnectionOk => 'DB-anslutning OK';

  @override
  String get dbNoConnection => 'Ingen anslutning';

  @override
  String get logout => 'Logga ut';
}
