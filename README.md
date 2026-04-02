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

### 3. Käynnistys

```bash
flutter run -d chrome --dart-define-from-file=.env.local --web-port=8080
```

tai Windows-pikakomenolla:

```bat
runlocal.bat
```

> Portti **8080** täytyy vastata `.env.local`-tiedostossa määritettyä `AZURE_REDIRECT_URI`-osoitetta.

## Docker

### Paikallinen kontti

```bash
docker compose up --build
```

`docker-compose.yml` käyttää `.env.local`-tiedostoa backendille ja välittää Azure-muuttujat build-argumentteina.

### Tuotantokuva käsin

```bash
docker build \
  --build-arg API_BASE_URL=https://api.esimerkki.fi \
  --build-arg AZURE_CLIENT_ID=<client-id> \
  --build-arg AZURE_TENANT_ID=<tenant-id> \
  -t jkrfront .
```

Kuva rakentuu kaksivaiheisesti: Flutter buildaa staattisen web-paketin, nginx ajaa sitä portissa 8080.

## Azure-deployaus

Frontend deployataan **Azure Container App**:na tai **Azure Static Web App**:na.

Build-aikaiset ympäristömuuttujat (`API_BASE_URL`, `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`) syötetään Container Registryn build-argumentteina tai CI/CD-putken salaisuuksina — ne eivät tule ajonaikaisesti ympäristöstä, vaan kompiloidaan suoraan Flutter-binääriin `--dart-define`-mekanismilla.

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
