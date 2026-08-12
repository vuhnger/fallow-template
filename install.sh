#!/usr/bin/env bash
#
# Kopierer fallow-oppsettet inn i et eksisterende repo.
#
#   ./install.sh /sti/til/repo
#
# Overskriver ingenting: filer som allerede finnes hoppes over og listes til
# slutt, så du kan flette manuelt.

set -euo pipefail

TARGET="${1:-}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/template"

if [[ -z "$TARGET" ]]; then
  echo "bruk: $0 <sti-til-repo>" >&2
  exit 2
fi

if [[ ! -d "$TARGET/.git" ]]; then
  echo "feil: $TARGET er ikke et git-repo" >&2
  exit 1
fi

skipped=()

copy() {
  local from="$1" to="$2"
  if [[ -e "$TARGET/$to" ]]; then
    skipped+=("$to")
    return
  fi
  mkdir -p "$TARGET/$(dirname "$to")"
  cp "$SRC/$from" "$TARGET/$to"
  echo "  + $to"
}

echo "Installerer fallow-oppsett i $TARGET"
copy ".github/workflows/code-scan.yml" ".github/workflows/code-scan.yml"
copy ".fallowrc.json" ".fallowrc.json"
copy ".fallow-gitignore" ".fallow/.gitignore"

if [[ ${#skipped[@]} -gt 0 ]]; then
  echo
  echo "Hoppet over (finnes fra før):"
  printf '  - %s\n' "${skipped[@]}"
fi

echo
echo "Gjenstår manuelt:"
echo "  1. Sjekk at repoet har .nvmrc og packageManager i package.json"
echo "     (workflowen leser node-versjon fra .nvmrc og pnpm-versjon fra package.json)"
echo "  2. Kjør 'npx fallow@3.15.0 audit' lokalt og tilpass entry/ignore i .fallowrc.json"
echo "  3. Gjør 'Dead Code' til required check i branch protection når basen er ren"
