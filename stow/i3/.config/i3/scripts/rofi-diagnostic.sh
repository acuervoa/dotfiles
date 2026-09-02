#!/usr/bin/env bash

log="${XDG_STATE_HOME:-$HOME/.local/state}/rofi/mod-d.log"
mkdir -p -- "$(dirname -- "$log")"

{
  date --iso-8601=seconds
  printf 'DISPLAY=%s WAYLAND_DISPLAY=%s\n' "${DISPLAY-}" "${WAYLAND_DISPLAY-}"
  /usr/bin/rofi -show drun -show-icons -font 'MesloLGLDZ Nerd Font 10'
  printf 'exit=%s\n' "$?"
} >>"$log" 2>&1
