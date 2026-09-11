# Deploy: SWA:n IP-rajaus

## Miksi `web/staticwebapp.config.json` ei sisällä IP-osoitteita

Azure Static Web Appsissa `networking.allowedIpRanges` on osa **sivuston sisältöä**,
ei Azure-resurssin asetusta. Sitä ei voi asettaa `az`-komennolla: sen on oltava
konfiguraatiotiedostossa, jonka deploy lataa mukanaan.

Lista pidetään silti **pois repostaan** ja injektoidaan vasta deploy-hetkellä.
Tässä tiedostossa oleva `staticwebapp.config.json` sisältää siis tarkoituksella
vain `navigationFallback`in. Älä lisää `networking`-lohkoa tänne.

## Mistä osoitteet tulevat

Lista on tallessa **Azure Key Vaultissa**, secretissä `allowed-ip-ranges`, erikseen
kussakin ympäristössä:

| Ympäristö | Key Vault |
|-----------|-----------|
| dev       | `kv-lhh-h01s01-dev` |
| testi     | `kv-lhh-jatehuolto-testi` |
| tuotanto  | `kv-lhh-jatehuolto-prod` |

Deploy-skriptit hakevat sen automaattisesti, joten mitään ei tarvitse asettaa
käsin. Lähdejärjestys, ensimmäinen löytynyt voittaa:

1. `-AllowedIpRanges`-parametri
2. ympäristömuuttuja `ALLOWED_IP_RANGES`
3. Key Vault -secret `allowed-ip-ranges`

Skripti tulostaa aina minkä lähteen se valitsi. Julkaisuputkessa lähde on
GitHubin secret tai muuttuja — ks. snippet.

Listan päivitys Key Vaultiin:

```bash
az keyvault secret set --vault-name kv-lhh-jatehuolto-prod --name allowed-ip-ranges --content-type application/json --value '["192.0.2.10/32","198.51.100.25/32"]'
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

`swa-ip-injektio.snippet.yml` sisältää valmiin GitHub Actions -askelparin:
osoitteiden validointi + injektio konffiin, sekä Standard-tason varmistus.
Se **ei ole** `.github/workflows/`-kansiossa, jottei GitHub yritä ajaa sitä
sellaisenaan — kopioi askeleet omaan workflowhun.

Injektio on ajettava **ennen** deploy-askelta ja **samassa jobissa**:
tiedostomuutos ei kanna jobien yli.

jq-logiikka on testattu (jq 1.7.1) sekä kelvollisilla että kelvottomilla
syötteillä — `999.1.1.1`, `1.2.3.256`, `/99`, roska ja tyhjä torjutaan.

## Toistaiseksi: ps1-skriptit

Putken valmistumiseen asti deploy tehdään repon ulkopuolisilla
`deploy-swa.ps1`-skripteillä (yksi per ympäristö). Ne lukevat listan Key
Vaultista automaattisesti:

```powershell
# tavallinen ajo - lista tulee Key Vaultista, mitaan ei tarvitse asettaa:
.\deploy-swa.ps1

# ohita Key Vault ymparistomuuttujalla:
$env:ALLOWED_IP_RANGES = '["192.0.2.10/32"]'
.\deploy-swa.ps1

# tai suoraan parametrina (voittaa ympäristömuuttujan):
.\deploy-swa.ps1 -AllowedIpRanges '192.0.2.10/32,198.51.100.25'

# rajaus kokonaan pois (esim. jos se on lukinnut sinut ulos):
.\deploy-swa.ps1 -NoIpRestriction -SkipBuild
```
