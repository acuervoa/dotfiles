#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
i3_config="$repo_root/stow/i3/.config/i3/config"
start_script="$repo_root/stow/i3/.config/i3/scripts/ferdium-start.sh"

grep -F 'assign [class="(?i)^ferdium$"] "8:CHAT"' "$i3_config" >/dev/null
grep -F 'exec --no-startup-id ~/.config/i3/scripts/ferdium-start.sh' "$i3_config" >/dev/null
test -x "$start_script"
grep -F 'flatpak kill "$app_id"' "$start_script" >/dev/null
grep -F 'window_properties.class' "$start_script" >/dev/null

echo "i3 Ferdium startup contract: ok"
