#!/usr/bin/env bash

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --reload main &
polybar --reload secondary &

# for MONITOR in $(xrandr --query | grep " connected " | cut -d" " -f1); do
# 	MONITOR=$MONITOR polybar --reload mybar &
# done

# echo "Bars launched..."
