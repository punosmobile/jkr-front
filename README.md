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

```
lib/
├── core/
│   ├── auth/          # Azure AD / MSAL -integraatio
│   ├── config/        # Ympäristömuuttujat (EnvConfig)
│   ├── di/            # Riippuvuusinjektio (GetIt + Injectable)
│   ├── network/       # Dio-asiakas ja interceptorit
│   ├── router/        # Reititys (GoRouter)
│   └── theme/         # Material 3 -teema
├── features/
│   ├── auth/          # Kirjautumissivu
│   ├── documentation/ # Tietokantaskeeman dokumentaationäkymä
│   └── home/          # Etusivu ja tiedontuonti-UI
├── shared/
│   └── services/      # Lokitus, tallennus, analytiikka
└── l10n/              # Lokalisaatiot (fi, en, sv)
```

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
