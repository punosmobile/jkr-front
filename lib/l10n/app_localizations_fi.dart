// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'jkrfront';

  @override
  String get welcome => 'Tervetuloa';

  @override
  String get home => 'Koti';

  @override
  String get loading => 'Ladataan...';

  @override
  String get error => 'Virhe';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get sidebarOrgName => 'Lahden seudun\njätehuoltoviranomainen';

  @override
  String get sidebarAppName => 'JKR Tiedonhallinta';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navImport => 'Tietojen tuonti';

  @override
  String get navSharepoint => 'SharePoint';

  @override
  String get navRealtimeLog => 'Reaaliaikainen loki';

  @override
  String get navReports => 'Raportit';

  @override
  String get navBackups => 'Varmuuskopiot';

  @override
  String get navDbDocs => 'Tietokantadok.';

  @override
  String get navHelp => 'Ohjeet & tuki';

  @override
  String get navPlannedFeatures => 'Suunnitellut ominaisuudet';

  @override
  String get navTargets => 'Kohteet';

  @override
  String get navMap => 'Karttanäkymä';

  @override
  String get navDatabase => 'Tietokanta';

  @override
  String get navLogs => 'Lokit & historia';

  @override
  String get dbConnectionOk => 'Kantayhteys OK';

  @override
  String get dbNoConnection => 'Ei yhteyttä';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get loginBrandBadge => 'Lahti JKR';

  @override
  String get loginCompactDescription => 'Lahden Jätehuollon rekisteri kokoaa tiedonsyötön, seurannan ja raportoinnin samaan näkymään.';

  @override
  String get loginBrandTitle => 'Lahden Jätehuollon\nrekisteri';

  @override
  String get loginBrandDescription => 'Yhtenäinen käyttöliittymä tiedonsyöttöön, dokumentaatioon ja päivittäiseen seurantaan. Kirjaudu sisään Microsoft-tilillä.';

  @override
  String get loginTitle => 'Kirjaudu sisään';

  @override
  String get loginDescription => 'Käytä organisaatiosi Microsoft-tunnusta.';

  @override
  String get loginEnvironmentDevelopment => 'Kehitys';

  @override
  String get loginEnvironmentTest => 'Testi';

  @override
  String get loginEnvironmentProduction => 'Tuotanto';

  @override
  String get loginButton => 'Jatka Microsoft-tilillä';

  @override
  String get loginButtonLoading => 'Kirjaudutaan...';

  @override
  String get loginBrowserHint => 'Selain avaa Microsoftin kirjautumisen ja palauttaa sinut takaisin tähän sovellukseen.';

  @override
  String get loginErrorFailed => 'Kirjautuminen epäonnistui. Yritä uudelleen.';

  @override
  String get loginErrorGeneric => 'Kirjautumista ei voitu suorittaa juuri nyt.';

  @override
  String get reportsPageTitle => 'Excel-raportti';

  @override
  String get reportsPageDescription => 'Luo JKR-raportti valituilla rajauksilla. Valmis tiedosto tallennetaan oletuksena SharePointiin, ja raportin eteneminen näkyy tässä näkymässä reaaliajassa.';

  @override
  String get reportsFiltersTitle => 'Rajaukset';

  @override
  String get reportsFieldDate => 'Tarkastelupäivämäärä';

  @override
  String get reportsFieldMunicipality => 'Kunta';

  @override
  String get reportsFieldApartmentCount => 'Huoneistolukumäärä';

  @override
  String get reportsFieldUrbanArea => 'Taajaman rajaus';

  @override
  String get reportsFieldPropertyType => 'Kohdetyyppi';

  @override
  String get reportsFieldSewer => 'Viemäriverkosto';

  @override
  String get reportsInfoParallelRuns => 'Voit käynnistää useita raportteja rinnakkain samoilla tai uusilla rajauksilla. Jokainen ajo näkyy alla omana korttinaan, ja kortin voi pienentää pelkkään tilanäkymään. Peruuttaminen vaatii erillisen vahvistuksen.';

  @override
  String get reportsRunButton => 'Aja raportti';

  @override
  String get reportsRunNewButton => 'Aja uusi raportti';

  @override
  String get reportsCancelDialogTitle => 'Peruuta raportin luonti?';

  @override
  String get reportsCancelDialogContent => 'Raportin muodostus on käynnissä. Haluatko varmasti lähettää peruutuspyynnön?';

  @override
  String get reportsCancelDialogContinue => 'Jatka muodostusta';

  @override
  String get reportsCancelDialogConfirm => 'Peruuta raportti';

  @override
  String get reportsDateNoFilter => 'Ei päivämäärärajausta';

  @override
  String get reportsDateClearTooltip => 'Tyhjennä päivämäärä';

  @override
  String get reportsDateSelectTooltip => 'Valitse päivämäärä';

  @override
  String get reportsDatePickerHelp => 'Valitse tarkastelupäivä';

  @override
  String get reportsDatePickerCancel => 'Peruuta';

  @override
  String get reportsDatePickerConfirm => 'Valitse';

  @override
  String get reportsAllMunicipalities => 'Kaikki kunnat';

  @override
  String get reportsPropertyTypeAll => 'Kaikki / ei rajausta';

  @override
  String get reportsPropertyTypeResidential => 'Asuinkiinteistö';

  @override
  String get reportsPropertyTypeHapa => 'HAPA';

  @override
  String get reportsPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsPropertyTypeOther => 'Muu';

  @override
  String get reportsSewerAll => 'Kaikki';

  @override
  String get reportsSewerConnected => 'Viemäriverkostossa';

  @override
  String get reportsSewerNotConnected => 'Ei viemäriverkostossa';

  @override
  String get reportsApartmentsAll => 'Kaikki huoneistomäärät';

  @override
  String get reportsApartmentsMaxFour => 'Enintään neljä';

  @override
  String get reportsApartmentsMinFive => 'Vähintään viisi';

  @override
  String get reportsUrbanAreaNone => 'Ei rajausta';

  @override
  String get reportsUrbanAreaOver200 => 'Yli 200 asukasta';

  @override
  String get reportsUrbanAreaOver10000 => 'Yli 10 000 asukasta';

  @override
  String get reportsUrbanAreaBoth => 'Molemmat taajamarajaukset';

  @override
  String get reportsEventJustCompleted => 'Valmistui juuri nyt';

  @override
  String get reportsEventStarted => 'Uusi ajo käynnistyi';

  @override
  String get reportsCollapseTooltip => 'Pienennä';

  @override
  String get reportsExpandTooltip => 'Laajenna';

  @override
  String get reportsTaskLabel => 'Tehtävä';

  @override
  String get reportsIdentifierLabel => 'Tunniste';

  @override
  String get reportsStatusTitleReady => 'Valmis';

  @override
  String get reportsStatusTitleCurrent => 'Tilanne';

  @override
  String get reportsErrorTitle => 'Virhe';

  @override
  String get reportsFileLabel => 'Tiedosto';

  @override
  String get reportsSharepointLinkAvailableTitle => 'SharePoint-linkki saatavilla';

  @override
  String get reportsSharepointLinkAvailableCompleted => 'Raportti on avattavissa SharePointissa.';

  @override
  String get reportsSharepointLinkAvailableRunning => 'Raportin SharePoint-linkki on jo saatavilla, vaikka ajo on vielä käynnissä.';

  @override
  String get reportsSharepointNoticeTitle => 'SharePoint-huomio';

  @override
  String get reportsCancelButton => 'Peruuta raportin luonti';

  @override
  String get reportsCloseButton => 'Sulje';

  @override
  String get reportsRunStatusStarting => 'Raporttia käynnistetään';

  @override
  String get reportsRunStatusRunning => 'Raporttia muodostetaan';

  @override
  String get reportsRunStatusCancelling => 'Raporttia peruutetaan';

  @override
  String get reportsRunStatusCompleted => 'Raportti on luotu';

  @override
  String get reportsRunStatusFailed => 'Raportin luonti epäonnistui';

  @override
  String get reportsRunSubtitleRunning => 'Palvelin muodostaa raporttia taustalla. Näet tähän näkymään raportin viimeisimmän etenemistiedon.';

  @override
  String get reportsRunSubtitleCancelling => 'Peruutuspyyntö on lähetetty. Odota, että palvelin vahvistaa raportin pysäyttämisen.';

  @override
  String get reportsRunSubtitleCompleted => 'Raportti valmistui onnistuneesti. Voit sulkea tämän näkymän OK-painikkeella.';

  @override
  String get reportsRunSubtitleFailed => 'Raportin luonti pysähtyi virheeseen tai peruutukseen. Tarkista alla oleva viesti.';

  @override
  String get reportsParameterDayLabel => 'Päivä';

  @override
  String get reportsParameterDayNotFiltered => 'Ei rajattu';

  @override
  String get reportsParameterMunicipalityLabel => 'Kunta';

  @override
  String get reportsParameterApartmentsLabel => 'Huoneistot';

  @override
  String get reportsParameterApartmentsAll => 'Kaikki';

  @override
  String get reportsParameterApartmentsMaxFour => 'Enintään neljä';

  @override
  String get reportsParameterApartmentsMinFive => 'Vähintään viisi';

  @override
  String get reportsParameterUrbanAreaLabel => 'Taajama';

  @override
  String get reportsParameterUrbanAreaNone => 'Ei rajausta';

  @override
  String get reportsParameterUrbanAreaOver200 => 'Yli 200 asukasta';

  @override
  String get reportsParameterUrbanAreaOver10000 => 'Yli 10 000 asukasta';

  @override
  String get reportsParameterUrbanAreaBoth => 'Molemmat';

  @override
  String get reportsParameterPropertyTypeLabel => 'Kohdetyyppi';

  @override
  String get reportsParameterPropertyTypeAll => 'Kaikki';

  @override
  String get reportsParameterPropertyTypeResidential => 'Asuinkiinteistö';

  @override
  String get reportsParameterPropertyTypeHapa => 'HAPA';

  @override
  String get reportsParameterPropertyTypeBiohapa => 'Biohapa';

  @override
  String get reportsParameterPropertyTypeOther => 'Muu';

  @override
  String get reportsParameterSewerLabel => 'Viemäri';

  @override
  String get reportsParameterSewerAll => 'Kaikki';

  @override
  String get reportsParameterSewerConnected => 'Verkostossa';

  @override
  String get reportsParameterSewerNotConnected => 'Ei verkostossa';

  @override
  String get reportsPollingUpdating => 'Päivittyy';

  @override
  String get reportsPollingUpdatedJustNow => 'Päivitetty juuri nyt';

  @override
  String reportsPollingUpdatedSecondsAgo(int seconds) {
    return 'Päivitetty ${seconds}s sitten';
  }

  @override
  String get reportsButtonFetchingLink => 'Haetaan linkkiä';

  @override
  String get reportsButtonOpenReport => 'Avaa raportti';

  @override
  String get reportsStepFetchTargets => 'Haetaan kohdetiedot kannasta';

  @override
  String get reportsStepApplyObligationFilters => 'Sovelletaan velvoiterajaukset';

  @override
  String get reportsStepCreateReport => 'Muodostetaan raportti';

  @override
  String get reportsStepExportSharepoint => 'Viedään SharePointiin';

  @override
  String get reportsBannerSingleActive => 'Raportin luonti käynnissä';

  @override
  String reportsBannerMultipleActive(int count) {
    return '$count ajoa käynnissä';
  }

  @override
  String get reportsOkButton => 'OK';

  @override
  String get reportsBlocStartDescription => 'Raportin käynnistys';

  @override
  String get reportsBlocSubmittingStatus => 'Lähetetään pyyntöä palvelimelle...';

  @override
  String get reportsBlocCancellingStatus => 'Peruutetaan raportin luontia...';

  @override
  String get reportsBlocCancelled => 'Raportin luonti peruttiin.';

  @override
  String get reportsBlocCancelPending => 'Peruutuspyyntö lähetetty. Odotetaan palvelimen kuittausta...';

  @override
  String get reportsBlocProgressFallback => 'Raporttia muodostetaan...';

  @override
  String get reportsBlocCompletedStoredSharepoint => 'Raportti on luotu ja tallennettu SharePointiin.';

  @override
  String get reportsBlocCompletedWaitingLink => 'Raportti on luotu. Odotetaan SharePoint-linkkiä...';

  @override
  String get reportsBlocCompletedReadyWaitingLink => 'Raportti on valmis. Odotetaan SharePoint-linkkiä...';

  @override
  String get reportsBlocFailedGeneric => 'Raportin luonti epäonnistui.';

  @override
  String get reportsRepoFetchTasksFailed => 'Raporttitehtävien haku epäonnistui.';

  @override
  String get reportsRepoStartFailed => 'Raportin käynnistäminen epäonnistui.';

  @override
  String get reportsRepoFetchStatusFailed => 'Raportin tilan haku epäonnistui.';

  @override
  String get reportsRepoCancelRequested => 'Raportin peruutus pyydetty.';

  @override
  String get reportsRepoCancelFailed => 'Raportin peruuttaminen epäonnistui.';

  @override
  String get reportsRepoConnectionTimeout => 'Yhteys aikakatkaistiin. Yritä uudelleen.';

  @override
  String get reportsRepoConnectionError => 'Yhteyttä palvelimeen ei saatu muodostettua.';

  @override
  String get dashboardLoadError => 'Dashboardin tietojen lataus epäonnistui.';

  @override
  String get dashboardHeaderDescription => 'Yhteenveto viimeisimmistä ajokerroista, tuonneista ja järjestelmätapahtumista.';

  @override
  String get dashboardRefresh => 'Päivitä';

  @override
  String get dashboardSummaryObligationCheckRan => 'Velvoitetarkistus ajettu';

  @override
  String get dashboardSummaryLatestReportGenerated => 'Viimeisin raportti generoitu';

  @override
  String get dashboardSummaryLatestDecisionInDatabase => 'Uusin päätös kannassa';

  @override
  String get dashboardSummaryLatestCompostingNotice => 'Uusin kompostointi-ilmoitus';

  @override
  String get dashboardSummarySludgeTransportLatestEmptying => 'Lietekulj. viimeisin tyhjennys';

  @override
  String get dashboardSummaryFixedTransportLatestQuarter => 'Kiinteä kulj. viimeisin kvartaali';

  @override
  String get dashboardSummaryLatestImport => 'Viimeisin tuonti';

  @override
  String get dashboardViewDetailsTooltip => 'Näytä lisätiedot';

  @override
  String get dashboardLatestSystemEvents => 'Viimeisimmät järjestelmätapahtumat';

  @override
  String get dashboardNoSystemEvents => 'Järjestelmätapahtumia ei ole saatavilla.';

  @override
  String get dashboardImportLog => 'Tuontiloki';

  @override
  String get dashboardNoImportLog => 'Tuontilokia ei ole saatavilla.';

  @override
  String get dashboardImportLogTypeOther => 'Muu';

  @override
  String get dashboardNoData => 'Dashboardin tietoja ei ole saatavilla.';

  @override
  String get dashboardNoInfo => 'Ei tietoa';

  @override
  String get dashboardStatusCompleted => 'Valmis';

  @override
  String get dashboardStatusFailed => 'Virhe';

  @override
  String get dashboardStatusRunning => 'Käynnissä';

  @override
  String get dashboardStatusPending => 'Jonossa';

  @override
  String get dashboardImportDetailsTitle => 'Tuontilokin tiedot';

  @override
  String get dashboardSummaryDetailsDescription => 'Kaikki saatavilla olevat tiedot tästä näkymästä.';

  @override
  String get dashboardCloseTooltip => 'Sulje';

  @override
  String get dashboardCloseButton => 'Sulje';

  @override
  String get dashboardFieldId => 'ID';

  @override
  String get dashboardFieldDate => 'Päivämäärä';

  @override
  String get dashboardFieldTime => 'Kellonaika';

  @override
  String get dashboardFieldType => 'Tyyppi';

  @override
  String get dashboardFieldStatus => 'Status';

  @override
  String get dashboardFieldResult => 'Tulos';

  @override
  String get dashboardFieldCommand => 'Komento';

  @override
  String get dashboardFieldRunner => 'Suorittaja';

  @override
  String get dashboardFieldDetails => 'Lisätiedot';

  @override
  String get importAnalysisErrorNotRunnable => 'Tiedostoa ei voi ajaa sisään. Tiedoston sisältöä ei tunnistettu tai tiedosto on virheellinen.';

  @override
  String get importAnalysisErrorMissingResult => 'Tiedoston esianalyysi epäonnistui eikä backend palauttanut analyysitulosta.';
}
