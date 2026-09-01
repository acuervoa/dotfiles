#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check="$repo_root/scripts/check-desktop-configs.sh"

test -x "$check"
bash "$check" --static >/dev/null
bash "$check" --help | grep -Fq 'Valida de forma reproducible'

printf 'PASS: comprobación estática de i3/tmux\n'
