#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$(mktemp)"
trap 'rm -f -- "$output"' EXIT

if ! "$repo_root/scripts/check-desktop-configs.sh" --static >"$output" 2>&1; then
  cat "$output"
  exit 1
fi

# La presencia de paquetes solo se puede comprobar donde hay pacman; en un runner sin
# pacman --static la omite (INFO) y solo se valida el manifiesto.
if command -v pacman >/dev/null 2>&1; then
  rg -q '^PERS_GUI_PACKAGES_PRESENT=PASS$' "$output"
  ! rg -q '^MISSING_PACKAGES=.+$' "$output"
else
  rg -q 'sin pacman' "$output"
fi

printf '%s\n' '[OK] PERS-GUI package manifest check passed'
