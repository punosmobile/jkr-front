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

  /// No description provided for @reportsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Excel report'**
  String get reportsPageTitle;

  /// No description provided for @reportsPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a JKR report with the selected filters. The completed file is stored in SharePoint by default, and the progress is shown here in real time.'**
  String get reportsPageDescription;

  /// No description provided for @reportsFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get reportsFiltersTitle;

  /// No description provided for @reportsFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Reference date'**
  String get reportsFieldDate;

  /// No description provided for @reportsFieldMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get reportsFieldMunicipality;

  /// No description provided for @reportsFieldApartmentCount.
  ///
  /// In en, this message translates to:
  /// **'Apartment count'**
  String get reportsFieldApartmentCount;

  /// No description provided for @reportsFieldUrbanArea.
  ///
  /// In en, this message translates to:
  /// **'Urban area filter'**
  String get reportsFieldUrbanArea;

  /// No description provided for @reportsFieldPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get reportsFieldPropertyType;

  /// No description provided for @reportsFieldSewer.
  ///
  /// In en, this message translates to:
  /// **'Sewer network'**
  String get reportsFieldSewer;

  /// No description provided for @reportsInfoParallelRuns.
  ///
  /// In en, this message translates to:
  /// **'You can start multiple reports in parallel with the same or new filters. Each run is shown below as its own card, and the card can be collapsed into a compact status view. Cancellation requires separate confirmation.'**
  String get reportsInfoParallelRuns;

  /// No description provided for @reportsRunButton.
  ///
  /// In en, this message translates to:
  /// **'Run report'**
  String get reportsRunButton;

  /// No description provided for @reportsRunNewButton.
  ///
  /// In en, this message translates to:
  /// **'Run new report'**
  String get reportsRunNewButton;

  /// No description provided for @reportsCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel report generation?'**
  String get reportsCancelDialogTitle;

  /// No description provided for @reportsCancelDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Report generation is in progress. Do you really want to send a cancellation request?'**
  String get reportsCancelDialogContent;

  /// No description provided for @reportsCancelDialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue generation'**
  String get reportsCancelDialogContinue;

  /// No description provided for @reportsCancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel report'**
  String get reportsCancelDialogConfirm;

  /// No description provided for @reportsDateNoFilter.
  ///
  /// In en, this message translates to:
  /// **'No date filter'**
  String get reportsDateNoFilter;

  /// No description provided for @reportsDateClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get reportsDateClearTooltip;

  /// No description provided for @reportsDateSelectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get reportsDateSelectTooltip;

  /// No description provided for @reportsDatePickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Select reference date'**
  String get reportsDatePickerHelp;

  /// No description provided for @reportsDatePickerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reportsDatePickerCancel;

  /// No description provided for @reportsDatePickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get reportsDatePickerConfirm;

  /// No description provided for @reportsAllMunicipalities.
  ///
  /// In en, this message translates to:
  /// **'All municipalities'**
  String get reportsAllMunicipalities;

  /// No description provided for @reportsPropertyTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All / no filter'**
  String get reportsPropertyTypeAll;

  /// No description provided for @reportsPropertyTypeResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential property'**
  String get reportsPropertyTypeResidential;

  /// No description provided for @reportsPropertyTypeHapa.
  ///
  /// In en, this message translates to:
  /// **'HAPA'**
  String get reportsPropertyTypeHapa;

  /// No description provided for @reportsPropertyTypeBiohapa.
  ///
  /// In en, this message translates to:
  /// **'Biohapa'**
  String get reportsPropertyTypeBiohapa;

  /// No description provided for @reportsPropertyTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportsPropertyTypeOther;

  /// No description provided for @reportsSewerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsSewerAll;

  /// No description provided for @reportsSewerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to sewer network'**
  String get reportsSewerConnected;

  /// No description provided for @reportsSewerNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected to sewer network'**
  String get reportsSewerNotConnected;

  /// No description provided for @reportsApartmentsAll.
  ///
  /// In en, this message translates to:
  /// **'All apartment counts'**
  String get reportsApartmentsAll;

  /// No description provided for @reportsApartmentsMaxFour.
  ///
  /// In en, this message translates to:
  /// **'Up to four'**
  String get reportsApartmentsMaxFour;

  /// No description provided for @reportsApartmentsMinFive.
  ///
  /// In en, this message translates to:
  /// **'At least five'**
  String get reportsApartmentsMinFive;

  /// No description provided for @reportsUrbanAreaNone.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get reportsUrbanAreaNone;

  /// No description provided for @reportsUrbanAreaOver200.
  ///
  /// In en, this message translates to:
  /// **'More than 200 inhabitants'**
  String get reportsUrbanAreaOver200;

  /// No description provided for @reportsUrbanAreaOver10000.
  ///
  /// In en, this message translates to:
  /// **'More than 10,000 inhabitants'**
  String get reportsUrbanAreaOver10000;

  /// No description provided for @reportsUrbanAreaBoth.
  ///
  /// In en, this message translates to:
  /// **'Both urban area filters'**
  String get reportsUrbanAreaBoth;

  /// No description provided for @reportsEventJustCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed just now'**
  String get reportsEventJustCompleted;

  /// No description provided for @reportsEventStarted.
  ///
  /// In en, this message translates to:
  /// **'New run started'**
  String get reportsEventStarted;

  /// No description provided for @reportsCollapseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get reportsCollapseTooltip;

  /// No description provided for @reportsExpandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get reportsExpandTooltip;

  /// No description provided for @reportsTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get reportsTaskLabel;

  /// No description provided for @reportsIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get reportsIdentifierLabel;

  /// No description provided for @reportsStatusTitleReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get reportsStatusTitleReady;

  /// No description provided for @reportsStatusTitleCurrent.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportsStatusTitleCurrent;

  /// No description provided for @reportsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get reportsErrorTitle;

  /// No description provided for @reportsFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get reportsFileLabel;

  /// No description provided for @reportsSharepointLinkAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'SharePoint link available'**
  String get reportsSharepointLinkAvailableTitle;

  /// No description provided for @reportsSharepointLinkAvailableCompleted.
  ///
  /// In en, this message translates to:
  /// **'The report can now be opened in SharePoint.'**
  String get reportsSharepointLinkAvailableCompleted;

  /// No description provided for @reportsSharepointLinkAvailableRunning.
  ///
  /// In en, this message translates to:
  /// **'The SharePoint link is already available even though the run is still in progress.'**
  String get reportsSharepointLinkAvailableRunning;

  /// No description provided for @reportsSharepointNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'SharePoint notice'**
  String get reportsSharepointNoticeTitle;

  /// No description provided for @reportsCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel report generation'**
  String get reportsCancelButton;

  /// No description provided for @reportsCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get reportsCloseButton;

  /// No description provided for @reportsRunStatusStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting report'**
  String get reportsRunStatusStarting;

  /// No description provided for @reportsRunStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Generating report'**
  String get reportsRunStatusRunning;

  /// No description provided for @reportsRunStatusCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling report'**
  String get reportsRunStatusCancelling;

  /// No description provided for @reportsRunStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Report created'**
  String get reportsRunStatusCompleted;

  /// No description provided for @reportsRunStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Report generation failed'**
  String get reportsRunStatusFailed;

  /// No description provided for @reportsRunSubtitleRunning.
  ///
  /// In en, this message translates to:
  /// **'The server is generating the report in the background. You can see the latest progress information here.'**
  String get reportsRunSubtitleRunning;

  /// No description provided for @reportsRunSubtitleCancelling.
  ///
  /// In en, this message translates to:
  /// **'The cancellation request has been sent. Wait for the server to confirm that the report was stopped.'**
  String get reportsRunSubtitleCancelling;

  /// No description provided for @reportsRunSubtitleCompleted.
  ///
  /// In en, this message translates to:
  /// **'The report finished successfully. You can close this view with the OK button.'**
  String get reportsRunSubtitleCompleted;

  /// No description provided for @reportsRunSubtitleFailed.
  ///
  /// In en, this message translates to:
  /// **'Report generation stopped due to an error or cancellation. Check the message below.'**
  String get reportsRunSubtitleFailed;

  /// No description provided for @reportsParameterDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get reportsParameterDayLabel;

  /// No description provided for @reportsParameterDayNotFiltered.
  ///
  /// In en, this message translates to:
  /// **'Not filtered'**
  String get reportsParameterDayNotFiltered;

  /// No description provided for @reportsParameterMunicipalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get reportsParameterMunicipalityLabel;

  /// No description provided for @reportsParameterApartmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get reportsParameterApartmentsLabel;

  /// No description provided for @reportsParameterApartmentsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsParameterApartmentsAll;

  /// No description provided for @reportsParameterApartmentsMaxFour.
  ///
  /// In en, this message translates to:
  /// **'Up to four'**
  String get reportsParameterApartmentsMaxFour;

  /// No description provided for @reportsParameterApartmentsMinFive.
  ///
  /// In en, this message translates to:
  /// **'At least five'**
  String get reportsParameterApartmentsMinFive;

  /// No description provided for @reportsParameterUrbanAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Urban area'**
  String get reportsParameterUrbanAreaLabel;

  /// No description provided for @reportsParameterUrbanAreaNone.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get reportsParameterUrbanAreaNone;

  /// No description provided for @reportsParameterUrbanAreaOver200.
  ///
  /// In en, this message translates to:
  /// **'More than 200 inhabitants'**
  String get reportsParameterUrbanAreaOver200;

  /// No description provided for @reportsParameterUrbanAreaOver10000.
  ///
  /// In en, this message translates to:
  /// **'More than 10,000 inhabitants'**
  String get reportsParameterUrbanAreaOver10000;

  /// No description provided for @reportsParameterUrbanAreaBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get reportsParameterUrbanAreaBoth;

  /// No description provided for @reportsParameterPropertyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get reportsParameterPropertyTypeLabel;

  /// No description provided for @reportsParameterPropertyTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsParameterPropertyTypeAll;

  /// No description provided for @reportsParameterPropertyTypeResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential property'**
  String get reportsParameterPropertyTypeResidential;

  /// No description provided for @reportsParameterPropertyTypeHapa.
  ///
  /// In en, this message translates to:
  /// **'HAPA'**
  String get reportsParameterPropertyTypeHapa;

  /// No description provided for @reportsParameterPropertyTypeBiohapa.
  ///
  /// In en, this message translates to:
  /// **'Biohapa'**
  String get reportsParameterPropertyTypeBiohapa;

  /// No description provided for @reportsParameterPropertyTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportsParameterPropertyTypeOther;

  /// No description provided for @reportsParameterSewerLabel.
  ///
  /// In en, this message translates to:
  /// **'Sewer'**
  String get reportsParameterSewerLabel;

  /// No description provided for @reportsParameterSewerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportsParameterSewerAll;

  /// No description provided for @reportsParameterSewerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get reportsParameterSewerConnected;

  /// No description provided for @reportsParameterSewerNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get reportsParameterSewerNotConnected;

  /// No description provided for @reportsPollingUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get reportsPollingUpdating;

  /// No description provided for @reportsPollingUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get reportsPollingUpdatedJustNow;

  /// No description provided for @reportsPollingUpdatedSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {seconds}s ago'**
  String reportsPollingUpdatedSecondsAgo(int seconds);

  /// No description provided for @reportsButtonFetchingLink.
  ///
  /// In en, this message translates to:
  /// **'Fetching link'**
  String get reportsButtonFetchingLink;

  /// No description provided for @reportsButtonOpenReport.
  ///
  /// In en, this message translates to:
  /// **'Open report'**
  String get reportsButtonOpenReport;

  /// No description provided for @reportsStepFetchTargets.
  ///
  /// In en, this message translates to:
  /// **'Fetching target data from the database'**
  String get reportsStepFetchTargets;

  /// No description provided for @reportsStepApplyObligationFilters.
  ///
  /// In en, this message translates to:
  /// **'Applying obligation filters'**
  String get reportsStepApplyObligationFilters;

  /// No description provided for @reportsStepCreateReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report'**
  String get reportsStepCreateReport;

  /// No description provided for @reportsStepExportSharepoint.
  ///
  /// In en, this message translates to:
  /// **'Exporting to SharePoint'**
  String get reportsStepExportSharepoint;

  /// No description provided for @reportsBannerSingleActive.
  ///
  /// In en, this message translates to:
  /// **'Report generation in progress'**
  String get reportsBannerSingleActive;

  /// No description provided for @reportsBannerMultipleActive.
  ///
  /// In en, this message translates to:
  /// **'{count} runs active'**
  String reportsBannerMultipleActive(int count);

  /// No description provided for @reportsOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get reportsOkButton;

  /// No description provided for @reportsBlocStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Starting report'**
  String get reportsBlocStartDescription;

  /// No description provided for @reportsBlocSubmittingStatus.
  ///
  /// In en, this message translates to:
  /// **'Sending request to the server...'**
  String get reportsBlocSubmittingStatus;

  /// No description provided for @reportsBlocCancellingStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelling report generation...'**
  String get reportsBlocCancellingStatus;

  /// No description provided for @reportsBlocCancelled.
  ///
  /// In en, this message translates to:
  /// **'Report generation was cancelled.'**
  String get reportsBlocCancelled;

  /// No description provided for @reportsBlocCancelPending.
  ///
  /// In en, this message translates to:
  /// **'Cancellation request sent. Waiting for server confirmation...'**
  String get reportsBlocCancelPending;

  /// No description provided for @reportsBlocProgressFallback.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get reportsBlocProgressFallback;

  /// No description provided for @reportsBlocCompletedStoredSharepoint.
  ///
  /// In en, this message translates to:
  /// **'The report has been created and saved to SharePoint.'**
  String get reportsBlocCompletedStoredSharepoint;

  /// No description provided for @reportsBlocCompletedWaitingLink.
  ///
  /// In en, this message translates to:
  /// **'The report has been created. Waiting for the SharePoint link...'**
  String get reportsBlocCompletedWaitingLink;

  /// No description provided for @reportsBlocCompletedReadyWaitingLink.
  ///
  /// In en, this message translates to:
  /// **'The report is ready. Waiting for the SharePoint link...'**
  String get reportsBlocCompletedReadyWaitingLink;

  /// No description provided for @reportsBlocFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Report generation failed.'**
  String get reportsBlocFailedGeneric;

  /// No description provided for @reportsRepoFetchTasksFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetching report tasks failed.'**
  String get reportsRepoFetchTasksFailed;

  /// No description provided for @reportsRepoStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Starting the report failed.'**
  String get reportsRepoStartFailed;

  /// No description provided for @reportsRepoFetchStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetching report status failed.'**
  String get reportsRepoFetchStatusFailed;

  /// No description provided for @reportsRepoCancelRequested.
  ///
  /// In en, this message translates to:
  /// **'Report cancellation requested.'**
  String get reportsRepoCancelRequested;

  /// No description provided for @reportsRepoCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancelling the report failed.'**
  String get reportsRepoCancelFailed;

  /// No description provided for @reportsRepoConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out. Please try again.'**
  String get reportsRepoConnectionTimeout;

  /// No description provided for @reportsRepoConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get reportsRepoConnectionError;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard data failed.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Summary of the latest runs, imports, and system events.'**
  String get dashboardHeaderDescription;

  /// No description provided for @dashboardRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dashboardRefresh;

  /// No description provided for @dashboardSummaryObligationCheckRan.
  ///
  /// In en, this message translates to:
  /// **'Obligation check run'**
  String get dashboardSummaryObligationCheckRan;

  /// No description provided for @dashboardSummaryLatestReportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Latest report generated'**
  String get dashboardSummaryLatestReportGenerated;

  /// No description provided for @dashboardSummaryLatestDecisionInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Latest decision in database'**
  String get dashboardSummaryLatestDecisionInDatabase;

  /// No description provided for @dashboardSummaryLatestCompostingNotice.
  ///
  /// In en, this message translates to:
  /// **'Latest composting notice'**
  String get dashboardSummaryLatestCompostingNotice;

  /// No description provided for @dashboardSummarySludgeTransportLatestEmptying.
  ///
  /// In en, this message translates to:
  /// **'Sludge transport latest emptying'**
  String get dashboardSummarySludgeTransportLatestEmptying;

  /// No description provided for @dashboardSummaryFixedTransportLatestQuarter.
  ///
  /// In en, this message translates to:
  /// **'Fixed transport latest quarter'**
  String get dashboardSummaryFixedTransportLatestQuarter;

  /// No description provided for @dashboardSummaryLatestImport.
  ///
  /// In en, this message translates to:
  /// **'Latest import'**
  String get dashboardSummaryLatestImport;

  /// No description provided for @dashboardViewDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get dashboardViewDetailsTooltip;

  /// No description provided for @dashboardLatestSystemEvents.
  ///
  /// In en, this message translates to:
  /// **'Latest system events'**
  String get dashboardLatestSystemEvents;

  /// No description provided for @dashboardNoSystemEvents.
  ///
  /// In en, this message translates to:
  /// **'No system events available.'**
  String get dashboardNoSystemEvents;

  /// No description provided for @dashboardImportLog.
  ///
  /// In en, this message translates to:
  /// **'Import log'**
  String get dashboardImportLog;

  /// No description provided for @dashboardNoImportLog.
  ///
  /// In en, this message translates to:
  /// **'No import log available.'**
  String get dashboardNoImportLog;

  /// No description provided for @dashboardImportLogTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dashboardImportLogTypeOther;

  /// No description provided for @dashboardNoData.
  ///
  /// In en, this message translates to:
  /// **'Dashboard data is not available.'**
  String get dashboardNoData;

  /// No description provided for @dashboardNoInfo.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get dashboardNoInfo;

  /// No description provided for @dashboardStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboardStatusCompleted;

  /// No description provided for @dashboardStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get dashboardStatusFailed;

  /// No description provided for @dashboardStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get dashboardStatusRunning;

  /// No description provided for @dashboardStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get dashboardStatusPending;

  /// No description provided for @dashboardImportDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import log details'**
  String get dashboardImportDetailsTitle;

  /// No description provided for @dashboardSummaryDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'All available details for this view.'**
  String get dashboardSummaryDetailsDescription;

  /// No description provided for @dashboardCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dashboardCloseTooltip;

  /// No description provided for @dashboardCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dashboardCloseButton;

  /// No description provided for @dashboardFieldId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get dashboardFieldId;

  /// No description provided for @dashboardFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dashboardFieldDate;

  /// No description provided for @dashboardFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get dashboardFieldTime;

  /// No description provided for @dashboardFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get dashboardFieldType;

  /// No description provided for @dashboardFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashboardFieldStatus;

  /// No description provided for @dashboardFieldResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get dashboardFieldResult;

  /// No description provided for @dashboardFieldCommand.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get dashboardFieldCommand;

  /// No description provided for @dashboardFieldRunner.
  ///
  /// In en, this message translates to:
  /// **'Runner'**
  String get dashboardFieldRunner;

  /// No description provided for @dashboardFieldDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dashboardFieldDetails;
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
