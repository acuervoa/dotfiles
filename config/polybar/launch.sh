#!/usr/bin/env bash
# set -euo pipefail
#
# # Cierra instancias previas
# killall -q polybar || true
# while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done
#
# # Lanza por monitor detectado
# if commnad -v xrandr >/dev/null 2>&1; then
#   primary="$(xrandr --query | awk '/ primary/{print $1; exit}')"
#   if [ -n "${primary:-}" ]; then
#     MONITOR="$primary" polybar --reload main &
#   else
#     first="$(polybar -m | head -n1 | cut -d: -f1)"
#     MONITOR="$first" polybar --reload main &
#   fi
#   # Resto de monitores -> barra secundaria
#   while read -r m; do
#     [ "$m" = "${primary:-}" ] && continue
#     MONITOR="$m" polybar --reload secondary &
#   done < <(polybar -m | cut d: -f1 | tail -n +2)
# else
#   polybar --reload main &
# fi
#
# disown
#
killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --reload main &
polybar --reload secondary &

# for MONITOR in $(xrandr --query | grep " connected " | cut -d" " -f1); do
# 	MONITOR=$MONITOR polybar --reload mybar &
# done

# echo "Bars launched..."
