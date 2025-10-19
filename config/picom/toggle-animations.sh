#!/usr/bin/env bash
set -euo pipefail

conf="$HOME/.config/picom/picom.conf"
[[ -f "$HOME/.config/picom.conf" ]] && conf="$HOME/.config/picom.conf"

mode="${1:-}"
if [[ "$mode" != "on" && "$mode" != "off" ]]; then
  echo "Uso: $(basename "$0") {on|off}"
  exit 2
fi

ver="$(picom --version 2>/dev/null || true)"
if ! echo "$ver" | grep -qiE 'ibhagwan|jonaburg'; then
  echo "[WARN] Tu picom parece upstream, las claves de animación pueden no existir."
fi

backup="$conf.$(date +%F-%H%M%S).bak"
cp -a "$conf" "$backup"
echo "[OK] Backup en $backup"

if [[ "$mode" == "on" ]]; then
  # descomentar las líneas de animación si están comentadas
  sed -i -E 's/^\s*#\s*(animations\s*=)/\1/' "$conf"
  sed -i -E 's/^\s*#\s*(animation-[a-zA-Z_-]+\s*=)/\1/' "$conf"
  sed -i -E 's/^\s*#\s*(animation_for-[a-zA-Z_-]+\s*=)/\1/' "$conf" || true
  sed -i -E 's/^\s*#\s*(animation-for-[a-zA-Z_-]+\s*=)/\1/' "$conf" || true
  msg="ON"
else
  # comentar las líneas de animación si están activas
  sed -i -E '/^\s*#/! s/^\s*(animations\s*=.*)/#\1/' "$conf"
  sed -i -E '/^\s*#/! s/^\s*(animation-[a-zA-Z_-]+\s*=.*)/#\1/' "$conf"
  sed -i -E '/^\s*#/! s/^\s*(animation_for-[a-zA-Z_-]+\s*=.*)/#\1/' "$conf" || true
  sed -i -E '/^\s*#/! s/^\s*(animation-for-[a-zA-Z_-]+\s*=.*)/#\1/' "$conf" || true
  msg="OFF"
fi

pkill -x picom 2>/dev/null || true
nohup picom --config "$conf" --log-level=warn >/tmp/picom.log 2>&1 &
disown
command -v notify-send >/dev/null 2>&1 && notify-send "Picom animations: $msg"
echo "[OK] Animations: $msg — log en /tmp/picom.log"
