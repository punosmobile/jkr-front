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

  @override
  String get loginBrandBadge => 'Lahti JKR';

  @override
  String get loginCompactDescription => 'Lahtis avfallsregister samlar datainmatning, uppföljning och rapportering i en vy.';

  @override
  String get loginBrandTitle => 'Lahtis avfalls\nregister';

  @override
  String get loginBrandDescription => 'Ett enhetligt gränssnitt för datainmatning, dokumentation och daglig uppföljning. Logga in med ditt Microsoft-konto.';

  @override
  String get loginTitle => 'Logga in';

  @override
  String get loginDescription => 'Använd din organisations Microsoft-konto.';

  @override
  String get loginEnvironmentDevelopment => 'Utveckling';

  @override
  String get loginEnvironmentTest => 'Test';

  @override
  String get loginEnvironmentProduction => 'Produktion';

  @override
  String get loginButton => 'Fortsätt med Microsoft';

  @override
  String get loginButtonLoading => 'Loggar in...';

  @override
  String get loginBrowserHint => 'Webbläsaren öppnar Microsoft-inloggning och återvänder sedan till den här applikationen.';

  @override
  String get loginErrorFailed => 'Inloggningen misslyckades. Försök igen.';

  @override
  String get loginErrorGeneric => 'Inloggningen kunde inte slutföras just nu.';

  @override
  String get reportsPageTitle => 'Excelrapport';

  @override
  String get reportsPageDescription => 'Skapa en JKR-rapport med de valda avgränsningarna. Den färdiga filen sparas som standard i SharePoint och rapportens framsteg visas här i realtid.';

  @override
  String get reportsFiltersTitle => 'Avgränsningar';

  @override
  String get reportsFieldDate => 'Granskningsdatum';

  @override
  String get reportsFieldMunicipality => 'Kommun';

  @override
  String get reportsFieldApartmentCount => 'Antal lägenheter';

  @override
  String get reportsFieldUrbanArea => 'Avgränsning för tätort';

  @override
  String get reportsFieldPropertyType => 'Typ av objekt';

  @override
  String get reportsFieldSewer => 'Avloppsnät';

  @override
  String get reportsInfoParallelRuns => 'Du kan starta flera rapporter parallellt med samma eller nya avgränsningar. Varje körning visas nedan i ett eget kort, och kortet kan minimeras till en kompakt statusvy. Avbrytning kräver separat bekräftelse.';

  @override
  String get reportsRunButton => 'Skapa rapport';

  @override
  String get reportsRunNewButton => 'Skapa ny rapport';

  @override
  String get reportsCancelDialogTitle => 'Avbryt rapportskapandet?';

  @override
  String get reportsCancelDialogContent => 'Rapporten skapas fortfarande. Vill du verkligen skicka en avbrytningsbegäran?';

  @override
  String get reportsCancelDialogContinue => 'Fortsätt skapa';

  @override
  String get reportsCancelDialogConfirm => 'Avbryt rapport';

  @override
  String get reportsDateNoFilter => 'Ingen datumavgränsning';

  @override
  String get reportsDateClearTooltip => 'Rensa datum';

  @override
  String get reportsDateSelectTooltip => 'Välj datum';

  @override
  String get reportsDatePickerHelp => 'Välj granskningsdatum';

  @override
  String get reportsDatePickerCancel => 'Avbryt';

  @override
  String get reportsDatePickerConfirm => 'Välj';

  @override
  String get reportsAllMunicipalities => 'Alla kommuner';

  @override
  String get reportsPropertyTypeAll => 'Alla / ingen avgränsning';

  @override
  String get reportsPropertyTypeResidential => 'Bostadsfastighet';

  @override
  String get reportsPropertyTypeHapa => 'HAPA';

  @override
  String get reportsPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsPropertyTypeOther => 'Annan';

  @override
  String get reportsSewerAll => 'Alla';

  @override
  String get reportsSewerConnected => 'I avloppsnätet';

  @override
  String get reportsSewerNotConnected => 'Inte i avloppsnätet';

  @override
  String get reportsApartmentsAll => 'Alla lägenhetsantal';

  @override
  String get reportsApartmentsMaxFour => 'Högst fyra';

  @override
  String get reportsApartmentsMinFive => 'Minst fem';

  @override
  String get reportsUrbanAreaNone => 'Ingen avgränsning';

  @override
  String get reportsUrbanAreaOver200 => 'Över 200 invånare';

  @override
  String get reportsUrbanAreaOver10000 => 'Över 10 000 invånare';

  @override
  String get reportsUrbanAreaBoth => 'Båda tätortsavgränsningarna';

  @override
  String get reportsEventJustCompleted => 'Blev klar nyss';

  @override
  String get reportsEventStarted => 'Ny körning startade';

  @override
  String get reportsCollapseTooltip => 'Minimera';

  @override
  String get reportsExpandTooltip => 'Expandera';

  @override
  String get reportsTaskLabel => 'Uppgift';

  @override
  String get reportsIdentifierLabel => 'Identifierare';

  @override
  String get reportsStatusTitleReady => 'Klar';

  @override
  String get reportsStatusTitleCurrent => 'Läge';

  @override
  String get reportsErrorTitle => 'Fel';

  @override
  String get reportsFileLabel => 'Fil';

  @override
  String get reportsSharepointLinkAvailableTitle => 'SharePoint-länk tillgänglig';

  @override
  String get reportsSharepointLinkAvailableCompleted => 'Rapporten kan nu öppnas i SharePoint.';

  @override
  String get reportsSharepointLinkAvailableRunning => 'SharePoint-länken är redan tillgänglig även om körningen fortfarande pågår.';

  @override
  String get reportsSharepointNoticeTitle => 'SharePoint-anmärkning';

  @override
  String get reportsCancelButton => 'Avbryt rapportskapandet';

  @override
  String get reportsCloseButton => 'Stäng';

  @override
  String get reportsRunStatusStarting => 'Startar rapport';

  @override
  String get reportsRunStatusRunning => 'Rapporten skapas';

  @override
  String get reportsRunStatusCancelling => 'Rapporten avbryts';

  @override
  String get reportsRunStatusCompleted => 'Rapporten har skapats';

  @override
  String get reportsRunStatusFailed => 'Det gick inte att skapa rapporten';

  @override
  String get reportsRunSubtitleRunning => 'Servern skapar rapporten i bakgrunden. Du kan se den senaste förloppsinformationen här.';

  @override
  String get reportsRunSubtitleCancelling => 'Avbrytningsbegäran har skickats. Vänta tills servern bekräftar att rapporten stoppades.';

  @override
  String get reportsRunSubtitleCompleted => 'Rapporten blev färdig. Du kan stänga vyn med OK-knappen.';

  @override
  String get reportsRunSubtitleFailed => 'Rapportskapandet stoppades på grund av ett fel eller en avbrytning. Kontrollera meddelandet nedan.';

  @override
  String get reportsParameterDayLabel => 'Dag';

  @override
  String get reportsParameterDayNotFiltered => 'Inte avgränsad';

  @override
  String get reportsParameterMunicipalityLabel => 'Kommun';

  @override
  String get reportsParameterApartmentsLabel => 'Lägenheter';

  @override
  String get reportsParameterApartmentsAll => 'Alla';

  @override
  String get reportsParameterApartmentsMaxFour => 'Högst fyra';

  @override
  String get reportsParameterApartmentsMinFive => 'Minst fem';

  @override
  String get reportsParameterUrbanAreaLabel => 'Tätort';

  @override
  String get reportsParameterUrbanAreaNone => 'Ingen avgränsning';

  @override
  String get reportsParameterUrbanAreaOver200 => 'Över 200 invånare';

  @override
  String get reportsParameterUrbanAreaOver10000 => 'Över 10 000 invånare';

  @override
  String get reportsParameterUrbanAreaBoth => 'Båda';

  @override
  String get reportsParameterPropertyTypeLabel => 'Typ av objekt';

  @override
  String get reportsParameterPropertyTypeAll => 'Alla';

  @override
  String get reportsParameterPropertyTypeResidential => 'Bostadsfastighet';

  @override
  String get reportsParameterPropertyTypeHapa => 'HAPA';

  @override
  String get reportsParameterPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsParameterPropertyTypeOther => 'Annan';

  @override
  String get reportsParameterSewerLabel => 'Avlopp';

  @override
  String get reportsParameterSewerAll => 'Alla';

  @override
  String get reportsParameterSewerConnected => 'I nätet';

  @override
  String get reportsParameterSewerNotConnected => 'Inte i nätet';

  @override
  String get reportsPollingUpdating => 'Uppdateras';

  @override
  String get reportsPollingUpdatedJustNow => 'Uppdaterad just nu';

  @override
  String reportsPollingUpdatedSecondsAgo(int seconds) {
    return 'Uppdaterad för ${seconds}s sedan';
  }

  @override
  String get reportsButtonFetchingLink => 'Hämtar länken';

  @override
  String get reportsButtonOpenReport => 'Öppna rapport';

  @override
  String get reportsStepFetchTargets => 'Hämtar objektuppgifter från databasen';

  @override
  String get reportsStepApplyObligationFilters => 'Tillämpar skyldighetsavgränsningar';

  @override
  String get reportsStepCreateReport => 'Skapar rapport';

  @override
  String get reportsStepExportSharepoint => 'Exporterar till SharePoint';

  @override
  String get reportsBannerSingleActive => 'Rapportskapande pågår';

  @override
  String reportsBannerMultipleActive(int count) {
    return '$count körningar pågår';
  }

  @override
  String get reportsOkButton => 'OK';

  @override
  String get reportsBlocStartDescription => 'Start av rapport';

  @override
  String get reportsBlocSubmittingStatus => 'Begäran skickas till servern...';

  @override
  String get reportsBlocCancellingStatus => 'Rapportskapandet avbryts...';

  @override
  String get reportsBlocCancelled => 'Rapportskapandet avbröts.';

  @override
  String get reportsBlocCancelPending => 'Avbrytningsbegäran har skickats. Väntar på bekräftelse från servern...';

  @override
  String get reportsBlocProgressFallback => 'Rapporten skapas...';

  @override
  String get reportsBlocCompletedStoredSharepoint => 'Rapporten har skapats och sparats i SharePoint.';

  @override
  String get reportsBlocCompletedWaitingLink => 'Rapporten har skapats. Väntar på SharePoint-länken...';

  @override
  String get reportsBlocCompletedReadyWaitingLink => 'Rapporten är klar. Väntar på SharePoint-länken...';

  @override
  String get reportsBlocFailedGeneric => 'Det gick inte att skapa rapporten.';

  @override
  String get reportsRepoFetchTasksFailed => 'Det gick inte att hämta rapportuppgifter.';

  @override
  String get reportsRepoStartFailed => 'Det gick inte att starta rapporten.';

  @override
  String get reportsRepoFetchStatusFailed => 'Det gick inte att hämta rapportens status.';

  @override
  String get reportsRepoCancelRequested => 'Begäran om att avbryta rapporten har skickats.';

  @override
  String get reportsRepoCancelFailed => 'Det gick inte att avbryta rapporten.';

  @override
  String get reportsRepoConnectionTimeout => 'Anslutningen tog för lång tid. Försök igen.';

  @override
  String get reportsRepoConnectionError => 'Det gick inte att ansluta till servern.';
}
