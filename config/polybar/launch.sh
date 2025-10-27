#!/usr/bin/env bash

killall -q polybar || true

while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 0.2
done

if command -v xrandr >/dev/null 2>&1; then
  mapfile -t monitors < <(xrandr --query | awk '/ connected/{print $1}')

  if [ "${#monitors[@]}" -gt 0 ]; then
    primary="$(xrandr --query | awk '/ primary/{print $1; exit}')"

    if [ -z "${primary:-}" ]; then
      primary="${monitors[0]}"
    fi

    MONITOR="$primary" polybar --reload main &

    for monitor in "${monitors[@]}"; do
      [ "$monitor" = "$primary" ] && continue
      MONITOR="$monitor" polybar --reload secondary &
    done
  else
    polybar --reload main &
  fi
else
  polybar --reload main &
fi

disown
