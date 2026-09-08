#!/usr/bin/env bash

set -euo pipefail

vars=(
    DISPLAY
    XAUTHORITY
    DESKTOP_SESSION
    XDG_SESSION_DESKTOP
    XDG_SESSION_TYPE
    XDG_CURRENT_DESKTOP
    XDG_SESSION_ID
    DBUS_SESSION_BUS_ADDRESS
)

present=()

for var in "${vars[@]}"; do
    if [[ -v "$var" ]]; then
        present+=("$var")
    fi
done

if ((${#present[@]})); then
    systemctl --user import-environment "${present[@]}"

    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        dbus-update-activation-environment \
            --systemd \
            "${present[@]}"
    fi
fi

systemctl --user reset-failed \
    i3-session.target \
    graphical-session.target \
    clipmenud.service \
    2>/dev/null || true

systemctl --user start i3-session.target
