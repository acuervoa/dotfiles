#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
es="$repo_root/docs/guia-practica-entorno.md"
en="$repo_root/docs/practical-environment-guide.md"

test -f "$es"
test -f "$en"

grep -Fq '## Modelo mental' "$es"
grep -Fq '## Arranque' "$es"
grep -Fq '## Workflow backend' "$es"
grep -Fq '## Git' "$es"
grep -Fq '## Logs' "$es"
grep -Fq '## Cierre y recuperación' "$es"
grep -Fq '## Ejercicios' "$es"

grep -Fq '## Mental model' "$en"
grep -Fq '## Startup' "$en"
grep -Fq '## Backend workflow' "$en"
grep -Fq '## Git' "$en"
grep -Fq '## Logs' "$en"
grep -Fq '## Closing and recovery' "$en"
grep -Fq '## Exercises' "$en"

for token in "C-s" "\$mod" "tproj" "<leader>pt" "lg" "dlogs" "clipmenu" "Atuin" "Rofi" "Yazi"; do
  grep -Fq "$token" "$es"
  grep -Fq "$token" "$en"
done

for file in "$es" "$en"; do
  grep -Fq 'SHORTCUTS.md' "$file"
  grep -Fq 'stow/nvim/.config/nvim/USAGE.md' "$file"
  grep -Fq 'audits/2026-09-01-neovim-workflows.md' "$file"
  grep -Fq 'audits/2026-09-02-application-integration.md' "$file"
done

printf '%s\n' 'PASS: guías práctica y English cubren la misma gramática'
