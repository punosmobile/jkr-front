# Deploy: SWA:n IP-rajaus

## Miksi `web/staticwebapp.config.json` ei sisällä IP-osoitteita

Azure Static Web Appsissa `networking.allowedIpRanges` on osa **sivuston sisältöä**,
ei Azure-resurssin asetusta. Sitä ei voi asettaa `az`-komennolla: sen on oltava
konfiguraatiotiedostossa, jonka deploy lataa mukanaan.

Lista pidetään silti **pois repostaan** ja injektoidaan vasta deploy-hetkellä.
Tässä tiedostossa oleva `staticwebapp.config.json` sisältää siis tarkoituksella
vain `navigationFallback`in. Älä lisää `networking`-lohkoa tänne.

## Mistä osoitteet tulevat

Lista on tallessa ympäristön **Azure Key Vaultissa**, secretissä `allowed-ip-ranges`.
Key Vaultin nimi on asetuksessa `KEYVAULT`: paikallisesti tiedostossa
`deploy/deploy.<env>.env`, putkessa environment-secretinä.

Deploy-skripti hakee sen automaattisesti, joten mitään ei tarvitse asettaa
käsin. Lähdejärjestys, ensimmäinen löytynyt voittaa:

1. ympäristömuuttuja `ALLOWED_IP_RANGES`
2. Key Vault -secret `allowed-ip-ranges`

Skripti tulostaa aina, minkä lähteen se valitsi. Putki ajaa samaa skriptiä,
joten siellä lista tulee Key Vaultista.

Listan päivitys Key Vaultiin:

```bash
az keyvault secret set --vault-name <keyvault> --name allowed-ip-ranges --content-type application/json --value '["192.0.2.10/32","198.51.100.25/32"]'
```

Muutos astuu voimaan vasta seuraavassa deployssa, koska rajaus on osa sisältöä.

Hyväksytyt muodot:

```
JSON-taulukko:  ["192.0.2.10/32","198.51.100.25/32"]
Erotinlista:    192.0.2.10/32,198.51.100.25/32
```

Erottimena käy pilkku, puolipiste, välilyönti tai rivinvaihto. Paljas osoite ilman
prefiksiä täydennetään `/32`:lla ja duplikaatit poistetaan.

**Puuttuva tai tyhjä lista keskeyttää deployn.** Tämä on tahallista: jos arvo
puuttuisi hiljaa, `networking` jäisi asettamatta ja sivusto avautuisi koko
internetiin ilman että kukaan huomaa.

## Vaatimus: Standard-taso

IP-rajaus toimii vain Standard-tasolla. Free-tasolla `networking`-lohko menee
deployssa läpi mutta **jää tehottomaksi ilman virheilmoitusta**, eli sivusto
näyttää rajatulta vaikka ei ole. Varmista taso ennen kuin luotat rajaukseen:

```bash
az staticwebapp show -n <swa> -g <rg> --query sku.name -o tsv
```

## Julkaisuputki

`.github/workflows/deploy.yml` julkaisee haaran sen omaan ympäristöön: develop → dev,
test → test ja main → tuotanto. Tuotanto odottaa hyväksyntää GitHubin environmentissa.
Workflow ajaa saman `deploy/deploy-frontend.sh`:n kuin paikallinen julkaisu.
Käsiajo: Actions → deploy → Run workflow ja ympäristön haara.

Azureen kirjaudutaan OIDC:llä frontin omalla identiteetillä. Se luottaa vain tähän
tiedostoon ympäristön haarasta, joten tiedoston nimeä ei voi vaihtaa.
Environment-secretit: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`,
`SUBSCRIPTION`, `RG`, `SWA` ja `KEYVAULT`.

## Flutter-versio ja riippuvuudet

Flutterin versio on `pubspec.yaml`:n `environment.flutter` (3.41.6). Putki asentaa
juuri sen, ja Dockerfilen image pidetään samassa versiossa. Käytä samaa versiota
myös paikallisesti: `flutter pub get` hylkää vanhemman version, mutta uudemman
se hyväksyy.

Riippuvuuksien versiot tulevat `pubspec.lock`:sta, joka on gitissä. Julkaisu
ajaa `flutter pub get --enforce-lockfile`, joten build kaatuu, jos lukitus ei
vastaa `pubspec.yaml`:ia. Kun riippuvuuksia muutetaan, aja `flutter pub get`
ja commitoi myös `pubspec.lock`.

## Deploy-skripti

`deploy/deploy-frontend.sh <dev|test|prod>` buildaa Flutter webin, kirjoittaa
`runtime_config.js`:n ja IP-rajauksen Key Vaultin arvoista ja julkaisee SWA:han.
Toimii Macilla ja Linuxilla (Windowsilla WSL tai Git Bash) sekä putkessa.

Esivaatimukset paikalliselle deploylle:

- `az` (Azure CLI), `jq`, `curl`, `flutter` ja `dart` (Flutter 3.41.6) sekä Node.js (`npx`).
- Apple Silicon -Macilla Rosetta 2: SWA CLI:n julkaisuohjelma `StaticSitesClient`
  on vain Intel-binääri, ja ilman Rosettaa julkaisu kaatuu virheeseen
  `spawn Unknown system error -86`. Asennus kerran:
  `softwareupdate --install-rosetta --agree-to-license`
- Lukuoikeus ympäristön Key Vaultin secreteihin (esim. rooli *Key Vault Secrets User*).

```bash
cp deploy/deploy.example.env deploy/deploy.dev.env   # arvot salasanahallinnasta
az login
deploy/deploy-frontend.sh dev                         # vain haarasta develop, puhdas työhakemisto
ALLOW_DIRTY=1 deploy/deploy-frontend.sh dev           # kokeilu mistä tahansa haarasta (ei tuotantoon)
ALLOWED_IP_RANGES='["192.0.2.10/32"]' deploy/deploy-frontend.sh dev   # ohittaa Key Vaultin listan
```

- Ilman IP-listaa julkaisua ei tehdä. Rajausta ei voi ohittaa: jos se lukitsee
  sinut ulos, päivitä Key Vaultin lista ja julkaise uudelleen.
- SWA:n on oltava Standard-tasolla. Skripti ei muuta Azure-resursseja.
- Tuloste ei sisällä osoitteita eikä tunnisteita, koska putken lokit ovat julkisia.

Vanhoja `deploy-swa.ps1`-skriptejä ei enää käytetä: ne eivät aseta IP-rajausta,
joten jokainen niillä tehty julkaisu poistaa sen.
