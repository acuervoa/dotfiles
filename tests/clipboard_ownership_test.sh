#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
i3_config="$repo_root/stow/i3/.config/i3/config"
tmux_config="$repo_root/stow/tmux/.tmux.conf"
kitty_config="$repo_root/stow/kitty/.config/kitty/kitty.conf"
nav="$repo_root/stow/bash/.bash_lib/nav.sh"

test -f "$i3_config"
test -f "$tmux_config"
test -f "$kitty_config"
test -f "$nav"

# Historial visual: clipmenu es el owner; CopyQ no se autoinicia.
grep -Fq 'CM_LAUNCHER=rofi clipmenu' "$i3_config"
! grep -Eq '^exec(_always)? .*copyq([[:space:]]|$)' "$i3_config"

# Transporte: cada capa conserva su fallback/interfaz sin apropiarse del historial.
grep -Fq '_clipboard_command()' "$nav"
grep -Fq 'set -g set-clipboard on' "$tmux_config"
grep -Fq 'map ctrl+shift+c copy_to_clipboard' "$kitty_config"
grep -Fq 'map ctrl+shift+v paste_from_clipboard' "$kitty_config"

printf '%s\n' 'PASS: clipmenu es historial y Bash/tmux/Kitty son transporte'
