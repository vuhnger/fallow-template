# fallow-template

GitHub Actions-oppsett for kodescanning med [fallow](https://github.com/fallow-rs/fallow) — død kode, ubrukte eksporter, ubrukte dependencies og health-metrikker. Ment å klones inn i nye repoer.

Forutsetter Node + pnpm.

## Bruk

```bash
git clone git@github.com:vuhnger/fallow-template.git
./fallow-template/install.sh /sti/til/nytt-repo
```

Scriptet overskriver aldri eksisterende filer — det lister det som ble hoppet over så du kan flette selv.

Eller bare kopier `template/` manuelt:

| Fra | Til |
| --- | --- |
| `template/.github/workflows/code-scan.yml` | `.github/workflows/code-scan.yml` |
| `template/.fallowrc.json` | `.fallowrc.json` |
| `template/.fallow-gitignore` | `.fallow/.gitignore` |

## Hva workflowen gjør

Kjører `fallow audit` på hver PR mot `main`, med `--base origin/<base_ref>`. Bare funn PR-en selv innfører feiler jobben — arvet gjeld rapporteres, men blokkerer ikke. Det gjør at du kan skru den på i et rotete repo uten å rydde alt først.

Detaljene:

- `fetch-depth: 0` fordi audit trenger merge-base.
- `pnpm install --frozen-lockfile` kjøres fordi fallow må kunne resolve imports til faktiske pakker.
- Node-versjon leses fra `.nvmrc`, pnpm-versjon fra `packageManager` i `package.json`. Ingen versjoner er pinnet i workflowen, så templaten trenger ikke redigeres per repo.
- Base-ref går via `env:`, ikke inline `${{ }}` i `run:`, så et grennavn aldri kan tolkes som shell.
- `permissions: contents: read` — jobben leser bare kode.
- fallow er pinnet til `3.15.0`. Bump bevisst; nye versjoner finner nye ting og kan gjøre grønne PR-er røde.
- Health-metrikkene, CRAP-score inkludert, kjører med fallows standardterskler. Ingen porter er overstyrt i templaten — juster i `.fallowrc.json` hvis et repo trenger det.

## Etter installasjon

1. Kjør `npx fallow@3.15.0 audit` lokalt.
2. Tilpass `entry` og `ignoreDependencies` i `.fallowrc.json` — skriv én kommentarlinje per unntak med hvorfor, ellers vokser lista uten at noen tør rydde.
3. Gjør `Dead Code` til required check i branch protection når basen er ren nok.
