# JKR Frontend

Flutter-pohjainen web-käyttöliittymä jätteenkuljetusrekisterin tiedonhallintatyökalulle. Mahdollistaa JKR-datan tuonnin, hallinnan ja seurannan selainkäyttöliittymästä.

## Arkkitehtuuri

```
jkrfront/          ← Flutter web (tämä projekti)
    ↕ HTTPS
jkr-core/          ← FastAPI backend (Azure Container App)
    ↕
PostgreSQL         ← Azure Flexible PostgreSQL
```

Käyttäjäautentikointi hoidetaan Azure AD:lla (MSAL). Roolit:
- **admin** – täydet oikeudet (tuontioperaatiot, tehtävien hallinta)
- **viewer** – lukuoikeus

## Paikalliset esitiedot

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.5.0
- Backend pyörimässä (ks. `jkr-core-development`)

## Paikallinen kehitysympäristö

### 1. Ympäristömuuttujat

Kopioi `.env.template` tiedostoksi `.env.local` ja täytä arvot:

```bash
cp .env.template .env.local
```

| Muuttuja | Kuvaus |
|---|---|
| `API_BASE_URL` | Backendin osoite, esim. `http://localhost:8000` |
| `AZURE_TENANT_ID` | Azure AD -vuokraajan tunnus |
| `AZURE_CLIENT_ID` | Azure AD -sovelluksen (frontend) client ID |
| `AZURE_ADMIN_GROUP_ID` | Azure AD -ryhmä admin-käyttäjille |
| `AZURE_VIEWER_GROUP_ID` | Azure AD -ryhmä viewer-käyttäjille |
| `AZURE_REDIRECT_URI` | OAuth-paluuosoite, esim. `http://localhost:8080` |

### 2. Riippuvuudet ja koodigeneraatio

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Käynnistys (Flutter dev-palvelin)

| | Komento |
|---|---|
| Windows | `runlocal.bat` |
| Linux/macOS | `chmod +x runlocal.sh && ./runlocal.sh` |

Tai suoraan:
```bash
flutter run -d chrome --dart-define-from-file=.env.local --web-port=8080
```

> Portti **8080** täytyy vastata `.env.local`-tiedostossa määritettyä `AZURE_REDIRECT_URI`-osoitetta.

## Docker (paikallinen)

Dockerilla ajettaessa frontend liittyy backendin Docker-verkkoon (`jkr-core-development_default`), joten molemmat täytyy olla käynnissä.

### 1. Käynnistä backend

```bash
cd ../jkr-core-development
docker compose -f dev.docker-compose.yml up
```

### 2. Buildaa frontend-image

| | Komento |
|---|---|
| Windows | `buildweb.bat` |
| Linux/macOS | `chmod +x buildweb.sh && ./buildweb.sh` |

Skripti buildaa ensin Flutter-webin paikallisesti ja sitten kevyen nginx-imagen (`Dockerfile.local`). Flutter-muutoksiin riittää jatkossa pelkkä `flutter build web --dart-define-from-file=.env.local` — imagea ei tarvitse rakentaa uudelleen.

### 3. Käynnistä frontend-kontti

| | Komento |
|---|---|
| Windows | `rundocker.bat` |
| Linux/macOS | `chmod +x rundocker.sh && ./rundocker.sh` |

`build/web` on mountattu konttiin, joten Flutter rebuild päivittää sisällön välittömästi.

### Tuotantokuva

```bash
docker build \
  --build-arg API_BASE_URL=https://api.esimerkki.fi \
  --build-arg AZURE_CLIENT_ID=<client-id> \
  --build-arg AZURE_TENANT_ID=<tenant-id> \
  -t jkrfront .
```

Tuotanto-Dockerfile (`Dockerfile`) rakentuu kaksivaiheisesti: Flutter kompiloi sisällä, nginx ajaa tulosta portissa 8080.

## Azure-deployaus

Frontend deployataan **Azure Container App**:na.

### Ympäristömuuttujat ajonaikaisesti

Konfiguraatioarvot eivät ole kompiloituina Flutter-binääriin. nginx generoi käynnistyessään `runtime_config.js`-tiedoston kontin ympäristömuuttujista (`docker/30-runtime-config.sh`). Flutter lukee arvot `window.runtimeConfig`-objektista — `--dart-define`-arvot toimivat fallbackina `flutter run` -ajossa.

Tämä mahdollistaa **saman Docker-imagen** käytön kaikissa ympäristöissä (dev / test / prod) vaihtamalla vain Container App:n ympäristömuuttujat.

| Muuttuja | Kuvaus |
|---|---|
| `API_BASE_URL` | Backendin osoite |
| `AZURE_CLIENT_ID` | Azure AD -sovelluksen client ID |
| `AZURE_TENANT_ID` | Azure AD -vuokraajan tunnus |
| `AZURE_REDIRECT_URI` | OAuth-paluuosoite |

## Projektirakenne

Sovellus noudattaa **feature-first** -arkkitehtuuria. Jokainen päänäkymä on oma feature-moduulinsa, ja yhteiset widgetit ja palvelut sijaitsevat `shared/`-hakemistossa. Authenticated-käyttäjän pääkehys on `AppShell`, joka sisältää sivupalkin (`AppSidebar`) ja sisältöalueen. Sivupalkista valittu näkymä renderöityy sisältöalueelle.

```
lib/
├── main.dart                        # Sovelluksen entry point
├── core/                            # Ydininfra, ei feature-kohtaista
│   ├── auth/                        # Azure AD / MSAL -integraatio
│   │   ├── auth_bloc.dart           #   BLoC: kirjautumistila
│   │   ├── auth_event.dart          #   BLoC-tapahtumat
│   │   ├── auth_service.dart        #   MSAL-palvelukutsut
│   │   ├── auth_state.dart          #   BLoC-tilat
│   │   └── msal_js_interop.dart     #   JS interop MSAL-kirjastolle
│   ├── config/
│   │   └── env_config.dart          #   Ympäristömuuttujat (runtime + dart-define)
│   ├── constants/
│   │   └── app_constants.dart       #   Sovellustason vakiot
│   ├── di/                          # Riippuvuusinjektio (GetIt + Injectable)
│   │   ├── injection.dart
│   │   ├── injection.config.dart    #   Generoitu
│   │   └── injectable_module.dart
│   ├── errors/                      # Poikkeukset ja virhemalllit
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/                  # Dart-laajennusmetodit
│   ├── network/                     # HTTP-asiakas
│   │   ├── dio_client.dart
│   │   ├── network_info.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── logging_interceptor.dart
│   ├── router/
│   │   └── app_router.dart          #   GoRouter-reititys + auth redirect
│   ├── theme/
│   │   └── app_theme.dart           #   Material 3 -teema, väripaletti
│   ├── utils/                       # Apufunktiot
│   └── widgets/                     # Core-tason yleiset widgetit
│
├── features/                        # Feature-moduulit (yksi per sivupalkin näkymä)
│   ├── auth/                        # Kirjautuminen
│   │   └── presentation/pages/
│   │       └── login_page.dart
│   │
│   ├── home/                        # Etusivu (ennen kirjautumisen jälkeistä AppShell-siirtymää)
│   │   ├── data/                    #   datasources/, models/, repositories/
│   │   ├── domain/                  #   entities/, repositories/, usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/home_page.dart
│   │       └── widgets/
│   │
│   ├── dashboard/                   # Dashboard — yleiskatsaus ja metriikat
│   │   └── presentation/pages/
│   │       └── dashboard_page.dart
│   │
│   ├── import/                      # Tietojen tuonti — tiedostovalinta, tuontijono, edistyminen
│   │   ├── data/
│   │   │   ├── models/              #   import_file.dart, import_queue_item.dart
│   │   │   └── repositories/       #   import_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/import_page.dart
│   │
│   ├── realtime_log/                # Reaaliaikainen loki — WebSocket + simulaatio
│   │   └── presentation/pages/
│   │       └── realtime_log_page.dart
│   │
│   ├── reports/                     # Raportit
│   │   └── presentation/pages/
│   │       └── reports_page.dart
│   │
│   ├── backups/                     # Varmuuskopiot
│   │   └── presentation/pages/
│   │       └── backups_page.dart
│   │
│   ├── documentation/               # Tietokantadokumentaatio — skeema/taulu/kenttä-selain
│   │   ├── data/
│   │   │   ├── models/              #   db_column_doc.dart (SchemaDoc, TableDoc, DbColumnDoc)
│   │   │   └── repositories/       #   documentation_repository.dart
│   │   └── presentation/
│   │       ├── bloc/                #   documentation_bloc/event/state
│   │       └── pages/documentation_page.dart
│   │
│   ├── help/                        # Ohjeet & tuki
│   │   └── presentation/pages/
│   │       └── help_page.dart
│   │
│   └── planned/                     # Suunnitellut ominaisuudet (placeholder-sivu)
│       └── presentation/pages/
│           └── planned_feature_page.dart
│
├── shared/
│   ├── services/
│   │   ├── logging/                 #   logger_service.dart
│   │   ├── storage/                 #   secure_storage_service.dart
│   │   └── analytics/
│   └── widgets/                     # Yhteiset UI-komponentit
│       ├── app_shell.dart           #   Pääkehys: sivupalkki + topbar + sisältöalue
│       ├── app_sidebar.dart         #   Sivupalkki ja navigaatioitemit
│       ├── card_container.dart      #   Yleinen kortti-wrapper
│       ├── metric_card.dart         #   Tilastokortti (arvo + trendi)
│       ├── responsive_grid.dart     #   Responsiivinen grid-layout
│       ├── status_badge.dart        #   Tilabadge (väri + teksti)
│       └── term_line.dart           #   Terminaalirivi (monofontti + väri)
│
└── l10n/                            # Lokalisaatiot (fi, en, sv)
```

### Sivupalkin näkymät ja vastaavat tiedostot

| Sivupalkki-item | Feature-moduuli | Sivutiedosto | Tila |
|---|---|---|---|
| Dashboard | `features/dashboard/` | `dashboard_page.dart` | Toteutettu (staattinen UI) |
| Tietojen tuonti | `features/import/` | `import_page.dart` | Toteutettu (BLoC + repository) |
| SharePoint | `features/import/` | `sharepoint_browser_page.dart` | Toteutettu (BLoC + backend API) |
| Reaaliaikainen loki | `features/realtime_log/` | `realtime_log_page.dart` | Toteutettu (WebSocket + simulaatio) |
| Raportit | `features/reports/` | `reports_page.dart` | Toteutettu (staattinen UI) |
| Varmuuskopiot | `features/backups/` | `backups_page.dart` | Toteutettu (staattinen UI) |
| Tietokantadok. | `features/documentation/` | `documentation_page.dart` | Toteutettu (BLoC + backend API) |
| Ohjeet & tuki | `features/help/` | `help_page.dart` | Toteutettu (staattinen UI) |
| Kohteet | – | `planned_feature_page.dart` | Suunniteltu |
| Karttanäkymä | – | `planned_feature_page.dart` | Suunniteltu |
| Tietokanta | – | `planned_feature_page.dart` | Suunniteltu |
| Lokit & historia | – | `planned_feature_page.dart` | Suunniteltu |

## Koodigeneraatio

Malleille, DI:lle ja API-asiakkaille käytetään koodigeneraatiota. Aja muutosten jälkeen:

```bash
dart run build_runner build --delete-conflicting-outputs
# tai kehityksen aikana jatkuvasti:
dart run build_runner watch --delete-conflicting-outputs
```

## Lokalisaatio

Lisää uusi avain PowerShell-apuskriptillä:

```powershell
.\add_l10n.ps1 <avain> <englanninkielinen_teksti>
```

Lokalisaatiotiedostot sijaitsevat hakemistossa `lib/l10n/`.

## Testit

```bash
flutter test
flutter test --coverage
```

## Teknologiat

| Osa-alue | Teknologia |
|---|---|
| Tila | flutter_bloc / BLoC |
| Riippuvuusinjektio | GetIt + Injectable |
| HTTP | Dio + Retrofit |
| Reititys | GoRouter |
| Tallennus | flutter_secure_storage, Hive |
| Autentikointi | MSAL (Azure AD) |
| Koodigeneraatio | Freezed, json_serializable, injectable_generator |
