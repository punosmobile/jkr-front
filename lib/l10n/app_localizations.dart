import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi'),
    Locale('sv')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'jkrfront'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Organization name in sidebar
  ///
  /// In en, this message translates to:
  /// **'Lahti region\nwaste management authority'**
  String get sidebarOrgName;

  /// Application name in sidebar
  ///
  /// In en, this message translates to:
  /// **'JKR Data Management'**
  String get sidebarAppName;

  /// Navigation: Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation: Data import
  ///
  /// In en, this message translates to:
  /// **'Data import'**
  String get navImport;

  /// Navigation: SharePoint
  ///
  /// In en, this message translates to:
  /// **'SharePoint'**
  String get navSharepoint;

  /// Navigation: Real-time log
  ///
  /// In en, this message translates to:
  /// **'Real-time log'**
  String get navRealtimeLog;

  /// Navigation: Reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Navigation: Backups
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get navBackups;

  /// Navigation: Database documentation
  ///
  /// In en, this message translates to:
  /// **'Database docs'**
  String get navDbDocs;

  /// Navigation: Help and support
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get navHelp;

  /// Section header: Planned features
  ///
  /// In en, this message translates to:
  /// **'Planned features'**
  String get navPlannedFeatures;

  /// Navigation: Targets
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get navTargets;

  /// Navigation: Map view
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get navMap;

  /// Navigation: Database
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get navDatabase;

  /// Navigation: Logs and history
  ///
  /// In en, this message translates to:
  /// **'Logs & history'**
  String get navLogs;

  /// Database connection status: connected
  ///
  /// In en, this message translates to:
  /// **'DB connection OK'**
  String get dbConnectionOk;

  /// Database connection status: disconnected
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get dbNoConnection;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Brand badge text shown on the login page
  ///
  /// In en, this message translates to:
  /// **'Lahti JKR'**
  String get loginBrandBadge;

  /// Compact header description shown on the login page
  ///
  /// In en, this message translates to:
  /// **'The Lahti Waste Management Register brings data entry, monitoring, and reporting into one view.'**
  String get loginCompactDescription;

  /// Large brand title shown on the login page
  ///
  /// In en, this message translates to:
  /// **'Lahti Waste Management\nRegister'**
  String get loginBrandTitle;

  /// Brand-side description shown on the login page
  ///
  /// In en, this message translates to:
  /// **'A unified interface for data entry, documentation, and daily follow-up. Sign in with your Microsoft account.'**
  String get loginBrandDescription;

  /// Login card title
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// Login card description
  ///
  /// In en, this message translates to:
  /// **'Use your organization\'s Microsoft account.'**
  String get loginDescription;

  /// Environment chip label for the development environment on the login page
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get loginEnvironmentDevelopment;

  /// Environment chip label for the test environment on the login page
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get loginEnvironmentTest;

  /// Environment chip label for the production environment on the login page
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get loginEnvironmentProduction;

  /// Primary login button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Microsoft'**
  String get loginButton;

  /// Primary login button label while loading
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginButtonLoading;

  /// Helper text below the login button
  ///
  /// In en, this message translates to:
  /// **'Your browser opens Microsoft sign-in and returns you to this application.'**
  String get loginBrowserHint;

  /// Error message shown when starting login fails without additional details
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get loginErrorFailed;

  /// Generic error message shown when login throws an unexpected error
  ///
  /// In en, this message translates to:
  /// **'Sign-in could not be completed right now.'**
  String get loginErrorGeneric;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fi', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fi': return AppLocalizationsFi();
    case 'sv': return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
