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

  @override
  String get reportsPageTitle => 'Excel report';

  @override
  String get reportsPageDescription => 'Create a JKR report with the selected filters. The completed file is stored in SharePoint by default, and the progress is shown here in real time.';

  @override
  String get reportsFiltersTitle => 'Filters';

  @override
  String get reportsFieldDate => 'Reference date';

  @override
  String get reportsFieldMunicipality => 'Municipality';

  @override
  String get reportsFieldApartmentCount => 'Apartment count';

  @override
  String get reportsFieldUrbanArea => 'Urban area filter';

  @override
  String get reportsFieldPropertyType => 'Property type';

  @override
  String get reportsFieldSewer => 'Sewer network';

  @override
  String get reportsInfoParallelRuns => 'You can start multiple reports in parallel with the same or new filters. Each run is shown below as its own card, and the card can be collapsed into a compact status view. Cancellation requires separate confirmation.';

  @override
  String get reportsRunButton => 'Run report';

  @override
  String get reportsRunNewButton => 'Run new report';

  @override
  String get reportsCancelDialogTitle => 'Cancel report generation?';

  @override
  String get reportsCancelDialogContent => 'Report generation is in progress. Do you really want to send a cancellation request?';

  @override
  String get reportsCancelDialogContinue => 'Continue generation';

  @override
  String get reportsCancelDialogConfirm => 'Cancel report';

  @override
  String get reportsDateNoFilter => 'No date filter';

  @override
  String get reportsDateClearTooltip => 'Clear date';

  @override
  String get reportsDateSelectTooltip => 'Select date';

  @override
  String get reportsDatePickerHelp => 'Select reference date';

  @override
  String get reportsDatePickerCancel => 'Cancel';

  @override
  String get reportsDatePickerConfirm => 'Select';

  @override
  String get reportsAllMunicipalities => 'All municipalities';

  @override
  String get reportsPropertyTypeAll => 'All / no filter';

  @override
  String get reportsPropertyTypeResidential => 'Residential property';

  @override
  String get reportsPropertyTypeHapa => 'HAPA';

  @override
  String get reportsPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsPropertyTypeOther => 'Other';

  @override
  String get reportsSewerAll => 'All';

  @override
  String get reportsSewerConnected => 'Connected to sewer network';

  @override
  String get reportsSewerNotConnected => 'Not connected to sewer network';

  @override
  String get reportsApartmentsAll => 'All apartment counts';

  @override
  String get reportsApartmentsMaxFour => 'Up to four';

  @override
  String get reportsApartmentsMinFive => 'At least five';

  @override
  String get reportsUrbanAreaNone => 'No filter';

  @override
  String get reportsUrbanAreaOver200 => 'More than 200 inhabitants';

  @override
  String get reportsUrbanAreaOver10000 => 'More than 10,000 inhabitants';

  @override
  String get reportsUrbanAreaBoth => 'Both urban area filters';

  @override
  String get reportsEventJustCompleted => 'Completed just now';

  @override
  String get reportsEventStarted => 'New run started';

  @override
  String get reportsCollapseTooltip => 'Collapse';

  @override
  String get reportsExpandTooltip => 'Expand';

  @override
  String get reportsTaskLabel => 'Task';

  @override
  String get reportsIdentifierLabel => 'Identifier';

  @override
  String get reportsStatusTitleReady => 'Ready';

  @override
  String get reportsStatusTitleCurrent => 'Status';

  @override
  String get reportsErrorTitle => 'Error';

  @override
  String get reportsFileLabel => 'File';

  @override
  String get reportsSharepointLinkAvailableTitle => 'SharePoint link available';

  @override
  String get reportsSharepointLinkAvailableCompleted => 'The report can now be opened in SharePoint.';

  @override
  String get reportsSharepointLinkAvailableRunning => 'The SharePoint link is already available even though the run is still in progress.';

  @override
  String get reportsSharepointNoticeTitle => 'SharePoint notice';

  @override
  String get reportsCancelButton => 'Cancel report generation';

  @override
  String get reportsCloseButton => 'Close';

  @override
  String get reportsRunStatusStarting => 'Starting report';

  @override
  String get reportsRunStatusRunning => 'Generating report';

  @override
  String get reportsRunStatusCancelling => 'Cancelling report';

  @override
  String get reportsRunStatusCompleted => 'Report created';

  @override
  String get reportsRunStatusFailed => 'Report generation failed';

  @override
  String get reportsRunSubtitleRunning => 'The server is generating the report in the background. You can see the latest progress information here.';

  @override
  String get reportsRunSubtitleCancelling => 'The cancellation request has been sent. Wait for the server to confirm that the report was stopped.';

  @override
  String get reportsRunSubtitleCompleted => 'The report finished successfully. You can close this view with the OK button.';

  @override
  String get reportsRunSubtitleFailed => 'Report generation stopped due to an error or cancellation. Check the message below.';

  @override
  String get reportsParameterDayLabel => 'Day';

  @override
  String get reportsParameterDayNotFiltered => 'Not filtered';

  @override
  String get reportsParameterMunicipalityLabel => 'Municipality';

  @override
  String get reportsParameterApartmentsLabel => 'Apartments';

  @override
  String get reportsParameterApartmentsAll => 'All';

  @override
  String get reportsParameterApartmentsMaxFour => 'Up to four';

  @override
  String get reportsParameterApartmentsMinFive => 'At least five';

  @override
  String get reportsParameterUrbanAreaLabel => 'Urban area';

  @override
  String get reportsParameterUrbanAreaNone => 'No filter';

  @override
  String get reportsParameterUrbanAreaOver200 => 'More than 200 inhabitants';

  @override
  String get reportsParameterUrbanAreaOver10000 => 'More than 10,000 inhabitants';

  @override
  String get reportsParameterUrbanAreaBoth => 'Both';

  @override
  String get reportsParameterPropertyTypeLabel => 'Property type';

  @override
  String get reportsParameterPropertyTypeAll => 'All';

  @override
  String get reportsParameterPropertyTypeResidential => 'Residential property';

  @override
  String get reportsParameterPropertyTypeHapa => 'HAPA';

  @override
  String get reportsParameterPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsParameterPropertyTypeOther => 'Other';

  @override
  String get reportsParameterSewerLabel => 'Sewer';

  @override
  String get reportsParameterSewerAll => 'All';

  @override
  String get reportsParameterSewerConnected => 'Connected';

  @override
  String get reportsParameterSewerNotConnected => 'Not connected';

  @override
  String get reportsPollingUpdating => 'Updating';

  @override
  String get reportsPollingUpdatedJustNow => 'Updated just now';

  @override
  String reportsPollingUpdatedSecondsAgo(int seconds) {
    return 'Updated ${seconds}s ago';
  }

  @override
  String get reportsButtonFetchingLink => 'Fetching link';

  @override
  String get reportsButtonOpenReport => 'Open report';

  @override
  String get reportsStepFetchTargets => 'Fetching target data from the database';

  @override
  String get reportsStepApplyObligationFilters => 'Applying obligation filters';

  @override
  String get reportsStepCreateReport => 'Generating report';

  @override
  String get reportsStepExportSharepoint => 'Exporting to SharePoint';

  @override
  String get reportsBannerSingleActive => 'Report generation in progress';

  @override
  String reportsBannerMultipleActive(int count) {
    return '$count runs active';
  }

  @override
  String get reportsOkButton => 'OK';

  @override
  String get reportsBlocStartDescription => 'Starting report';

  @override
  String get reportsBlocSubmittingStatus => 'Sending request to the server...';

  @override
  String get reportsBlocCancellingStatus => 'Cancelling report generation...';

  @override
  String get reportsBlocCancelled => 'Report generation was cancelled.';

  @override
  String get reportsBlocCancelPending => 'Cancellation request sent. Waiting for server confirmation...';

  @override
  String get reportsBlocProgressFallback => 'Generating report...';

  @override
  String get reportsBlocCompletedStoredSharepoint => 'The report has been created and saved to SharePoint.';

  @override
  String get reportsBlocCompletedWaitingLink => 'The report has been created. Waiting for the SharePoint link...';

  @override
  String get reportsBlocCompletedReadyWaitingLink => 'The report is ready. Waiting for the SharePoint link...';

  @override
  String get reportsBlocFailedGeneric => 'Report generation failed.';

  @override
  String get reportsRepoFetchTasksFailed => 'Fetching report tasks failed.';

  @override
  String get reportsRepoStartFailed => 'Starting the report failed.';

  @override
  String get reportsRepoFetchStatusFailed => 'Fetching report status failed.';

  @override
  String get reportsRepoCancelRequested => 'Report cancellation requested.';

  @override
  String get reportsRepoCancelFailed => 'Cancelling the report failed.';

  @override
  String get reportsRepoConnectionTimeout => 'The connection timed out. Please try again.';

  @override
  String get reportsRepoConnectionError => 'Could not connect to the server.';

  @override
  String get dashboardLoadError => 'Loading dashboard data failed.';

  @override
  String get dashboardHeaderDescription => 'Summary of the latest runs, imports, and system events.';

  @override
  String get dashboardRefresh => 'Refresh';

  @override
  String get dashboardSummaryObligationCheckRan => 'Obligation check run';

  @override
  String get dashboardSummaryLatestReportGenerated => 'Latest report generated';

  @override
  String get dashboardSummaryLatestDecisionInDatabase => 'Latest decision in database';

  @override
  String get dashboardSummaryLatestCompostingNotice => 'Latest composting notice';

  @override
  String get dashboardSummarySludgeTransportLatestEmptying => 'Sludge transport latest emptying';

  @override
  String get dashboardSummaryFixedTransportLatestQuarter => 'Fixed transport latest quarter';

  @override
  String get dashboardSummaryLatestImport => 'Latest import';

  @override
  String get dashboardViewDetailsTooltip => 'Show details';

  @override
  String get dashboardLatestSystemEvents => 'Latest system events';

  @override
  String get dashboardNoSystemEvents => 'No system events available.';

  @override
  String get dashboardImportLog => 'Import log';

  @override
  String get dashboardNoImportLog => 'No import log available.';

  @override
  String get dashboardImportLogTypeOther => 'Other';

  @override
  String get dashboardNoData => 'Dashboard data is not available.';

  @override
  String get dashboardNoInfo => 'No data';

  @override
  String get dashboardStatusCompleted => 'Completed';

  @override
  String get dashboardStatusFailed => 'Failed';

  @override
  String get dashboardStatusRunning => 'Running';

  @override
  String get dashboardStatusPending => 'Queued';

  @override
  String get dashboardImportDetailsTitle => 'Import log details';

  @override
  String get dashboardSummaryDetailsDescription => 'All available details for this view.';

  @override
  String get dashboardCloseTooltip => 'Close';

  @override
  String get dashboardCloseButton => 'Close';

  @override
  String get dashboardFieldId => 'ID';

  @override
  String get dashboardFieldDate => 'Date';

  @override
  String get dashboardFieldTime => 'Time';

  @override
  String get dashboardFieldType => 'Type';

  @override
  String get dashboardFieldStatus => 'Status';

  @override
  String get dashboardFieldResult => 'Result';

  @override
  String get dashboardFieldCommand => 'Command';

  @override
  String get dashboardFieldRunner => 'Runner';

  @override
  String get dashboardFieldDetails => 'Details';
}
