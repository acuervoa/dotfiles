#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }
need_cmd xrandr || exit 0
need_cmd polybar || exit 0

killall -q polybar || true
while pgrep -u "$UID" -x polybar >/dev/null 2>&1; do
  sleep 0.2
done

mapfile -t connected < <(xrandr --query | awk '/ connected/{print $1}')
((${#connected[@]})) || exit 0

internal=""
external=""

for o in "${connected[@]}"; do
  case "$o" in
  eDP* | LVDS*)
    internal="$o"
    break
    ;;
  esac
done

if [[ -z "$internal" ]]; then
  internal="$(xrandr --query | awk '/ connected primary/{print $1; exit}' || true)"
fi
if [[ -z "$internal" ]]; then
  internal="${connected[0]}"
fi

for o in "${connected[@]}"; do
  if [[ "$o" != "$internal" ]]; then
    external="$o"
    break
  fi
done

MONITOR="$internal" polybar -q main >/tmp/polybar-main.log 2>&1 &

if [[ -n "${external:-}" ]]; then
  MONITOR="$external" polybar -q secondary >/tmp/polybar-secondary.log 2>&1 &
fi
