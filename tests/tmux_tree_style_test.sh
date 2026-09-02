#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmux_config="$repo_root/stow/tmux/.tmux.conf"

test -f "$tmux_config"
grep -Fq 'setw -g mode-style "bg=#cba6f7,fg=#1e1e2e"' "$tmux_config"
grep -Fq 'setw -g tree-mode-preview-style "fg=#89b4fa"' "$tmux_config"
grep -Fq 'set -g message-style "bg=#1e1e2e,fg=#cba6f7,fill=#1e1e2e"' "$tmux_config"
grep -Fq 'set -g message-command-style "bg=#1e1e2e,fg=#f9e2af,fill=#1e1e2e"' "$tmux_config"

printf '%s\n' 'PASS: choose-tree usa estilos Catppuccin Mocha'
