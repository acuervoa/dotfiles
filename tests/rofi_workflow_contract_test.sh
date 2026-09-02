#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rofi_config="$repo_root/stow/rofi/.config/rofi/config.rasi"
i3_config="$repo_root/stow/i3/.config/i3/config"
close_script="$repo_root/stow/i3/.config/i3/scripts/confirm_kill.sh"

test -f "$rofi_config"
test -f "$i3_config"
test -x "$close_script"

grep -Fq 'kb-row-up: "Up,Control+p,Control+k"' "$rofi_config"
grep -Fq 'kb-row-down: "Down,Control+n,Control+j"' "$rofi_config"
grep -Fq 'kb-accept-entry: "Return,KP_Enter,Control+m"' "$rofi_config"
grep -Fq 'kb-cancel: "Escape,Control+g"' "$rofi_config"
grep -Fq 'bindsym $mod+d exec --no-startup-id rofi' "$i3_config"
grep -Fq 'bindsym $mod+f exec --no-startup-id rofi -show window' "$i3_config"
grep -Fq 'bindsym $mod+v exec --no-startup-id "CM_LAUNCHER=rofi clipmenu"' "$i3_config"
grep -Fq 'bindsym $mod+q exec --no-startup-id ~/.config/i3/scripts/confirm_kill.sh' "$i3_config"
grep -Fq -- '-no-custom' "$close_script"

printf '%s\n' 'PASS: Rofi es el selector visual keyboard-first de i3'
