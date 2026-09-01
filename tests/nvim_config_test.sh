#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check="$repo_root/scripts/check-nvim.sh"

test -x "$check"
bash "$check" --static
bash "$check" --help | grep -Fq 'Validación headless'
printf 'PASS: contrato del checker Neovim\n'
