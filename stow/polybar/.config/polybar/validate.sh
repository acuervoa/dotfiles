#!/usr/bin/env bash
set -euo pipefail

info() { printf '[polybar:validate][INFO] %s\n' "$*"; }
warn() { printf '[polybar:validate][WARN] %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$DIR/config.ini"
[ -f "$CFG" ] || {
  warn "No existe: $CFG"
  exit 1
}

scripts=(
  "$DIR/launch.sh"
  "$DIR/scripts/hook_refresh.sh"
  "$DIR/scripts/updates-pacman-aurhelper.sh"
  "$DIR/scripts/actualizar-sistema.sh"
  "$DIR/scripts/speedtest.sh"
  "$DIR/scripts/bluetooth-simple.sh"
  "$DIR/scripts/dunst-status.sh"
  "$DIR/scripts/dunst-toggle.sh"
  "$DIR/scripts/sensors_temp.sh"
)

missing=false
for s in "${scripts[@]}"; do
  if [ ! -f "$s" ]; then
    warn "Falta fichero: $s"
    missing=true
    continue
  fi
  [ -x "$s" ] || {
    warn "No es ejecutable: $s"
    missing=true
  }
done

for c in polybar notify-send nmcli; do have "$c" || warn "No encuentro comando: $c"; done
have checkupdates || warn "Falta checkupdates (pacman-contrib en Arch)"
have sensors || warn "Falta sensors (lm_sensors)"
have bluetoothctl || warn "Falta bluetoothctl (bluez-utils)"

[ "$missing" = "true" ] && exit 1
info "OK"
