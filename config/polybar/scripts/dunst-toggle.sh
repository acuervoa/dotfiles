#!/usr/bin/env bash
set -euo pipefail
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=/run/user/$(id -u)/bus"}

if dunstctl is-paused | grep -qi true; then
  dunstctl set-paused false
  notify-send -u low \
    -h string:x-dunst-stack-tag:dnd \
    -h string:transient:true \
    "Do Not Disturb" "Desactivado (notificaciones habilitadas)"
else
  dunstctl set-paused true
fi
