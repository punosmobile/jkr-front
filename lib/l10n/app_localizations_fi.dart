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
}
