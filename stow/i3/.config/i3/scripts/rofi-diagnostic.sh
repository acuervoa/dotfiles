#!/usr/bin/env bash

log="${XDG_STATE_HOME:-$HOME/.local/state}/rofi/mod-d.log"
mkdir -p -- "$(dirname -- "$log")"

pidfile="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/rofi.pid"
if test -r "$pidfile"; then
  pid="$(sed -n '1p' "$pidfile")"
  if [[ "$pid" =~ ^[0-9]+$ ]] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f -- "$pidfile"
  fi
fi

{
  date --iso-8601=seconds
  printf 'DISPLAY=%s WAYLAND_DISPLAY=%s\n' "${DISPLAY-}" "${WAYLAND_DISPLAY-}"
  /usr/bin/rofi -show drun -show-icons -font 'MesloLGLDZ Nerd Font 10'
  printf 'exit=%s\n' "$?"
} >>"$log" 2>&1
