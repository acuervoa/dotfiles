#!/usr/bin/env bash
set -euo pipefail
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=/run/user/$(id -u)/bus"}
/usr/bin/dunstctl set-paused toggle
