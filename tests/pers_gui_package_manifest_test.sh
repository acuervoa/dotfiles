#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$(mktemp)"
trap 'rm -f -- "$output"' EXIT

if ! "$repo_root/scripts/check-desktop-configs.sh" --static >"$output" 2>&1; then
  cat "$output"
  exit 1
fi

rg -q '^PERS_GUI_PACKAGES_PRESENT=PASS$' "$output"
! rg -q '^MISSING_PACKAGES=.+$' "$output"

printf '%s\n' '[OK] PERS-GUI package manifest check passed'
