#!/usr/bin/env bash
set -euo pipefail

app_id=org.ferdium.Ferdium

# A Flatpak sandbox can survive after its top-level window has disappeared.
# Do not let that stale process suppress the next graphical launch.
if flatpak ps --columns=application 2>/dev/null | grep -qFx "$app_id"; then
    if i3-msg -t get_tree 2>/dev/null |
        jq -e 'any(.. | objects; .window_properties? and ((.window_properties.class // "" | ascii_downcase) == "ferdium"))' >/dev/null; then
        exit 0
    fi

    flatpak kill "$app_id" >/dev/null 2>&1 || true
fi

exec flatpak run "$app_id"
