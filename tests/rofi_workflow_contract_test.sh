#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rofi_config="$repo_root/stow/rofi/.config/rofi/config.rasi"
i3_config="$repo_root/stow/i3/.config/i3/config"
close_script="$repo_root/stow/i3/.config/i3/scripts/confirm_kill.sh"
rofi_diagnostic="$repo_root/stow/i3/.config/i3/scripts/rofi-diagnostic.sh"
clipmenud_start="$repo_root/stow/i3/.config/i3/scripts/clipmenud-start.sh"

test -f "$rofi_config"
test -f "$i3_config"
test -x "$close_script"
test -x "$rofi_diagnostic"
test -x "$clipmenud_start"

grep -Fq 'kb-row-up: "Up,Control+p"' "$rofi_config"
grep -Fq 'kb-row-down: "Down,Control+n,Control+j"' "$rofi_config"
grep -Fq 'kb-accept-entry: "Return,KP_Enter,Control+m"' "$rofi_config"
grep -Fq 'kb-cancel: "Escape,Control+g"' "$rofi_config"
if grep -Fq 'bindsym $mod+d exec --no-startup-id rofi -modi run -show drun' "$i3_config"; then
  printf '%s\n' 'FAIL: $mod+d vuelve a deshabilitar drun' >&2
  exit 1
fi
grep -Fq 'bindsym $mod+d exec --no-startup-id ~/.config/i3/scripts/rofi-diagnostic.sh' "$i3_config"
grep -Fq 'mod-d.log' "$rofi_diagnostic"
grep -Fq 'rofi.pid' "$rofi_diagnostic"
grep -Fq 'kill -0' "$rofi_diagnostic"
grep -Fq 'rm -f -- "$pidfile"' "$rofi_diagnostic"
grep -Fq '2>&1' "$rofi_diagnostic"
grep -Fq 'bindsym $mod+f exec --no-startup-id rofi -show window' "$i3_config"
grep -Fq 'bindsym $mod+v exec --no-startup-id "CM_LAUNCHER=rofi clipmenu"' "$i3_config"
grep -Fq 'exec --no-startup-id ~/.config/i3/scripts/clipmenud-start.sh' "$i3_config"
grep -Fq 'bindsym $mod+q exec --no-startup-id ~/.config/i3/scripts/confirm_kill.sh' "$i3_config"
grep -Fq -- '-no-custom' "$close_script"

grep -Fq 'import-environment DISPLAY XAUTHORITY' "$clipmenud_start"
grep -Fq 'reset-failed clipmenud.service' "$clipmenud_start"
grep -Fq 'restart clipmenud.service' "$clipmenud_start"

printf '%s\n' 'PASS: Rofi es el selector visual keyboard-first de i3'
