#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/stow/tmux/.tmux.conf"

printf '# tmux plugin inventory\n\n'
printf '| Plugin | Source |\n| --- | --- |\n'
awk -F"'" '/^[[:space:]]*set -g @plugin / {print "| `" $2 "` | stow/tmux/.tmux.conf |"}' "$config"
printf '\n## Local consumers\n\n'
rg -n '#\(|run-shell|@plugin' "$config" | sed 's/^/- /'
printf '\n## Recommendations\n\n'
printf '%s\n' '- Medir cada plugin en una sesión limpia antes de retirarlo.'
printf '%s\n' '- Mantener los bindings core fuera de plugins cuando exista equivalencia.'
printf '%s\n' '- Cachear `git_status.sh` si el coste del status-right supera el presupuesto acordado.'
