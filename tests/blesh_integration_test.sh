#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
blerc="$repo_root/stow/blesh/.config/blesh/blerc"
keymap="$repo_root/stow/bash/.bash_lib/keymap.sh"

test -r /usr/share/blesh/ble.sh
test "$(grep -cE '^[[:space:]]*ble-attach[[:space:]]*$' "$repo_root/stow/bash/.bashrc")" -eq 1
grep -Fq 'source /usr/share/blesh/ble.sh --noattach' "$repo_root/stow/bash/.bashrc"
grep -Fq 'ble-import integration/fzf-completion' "$blerc"
grep -Fq 'ble-import integration/fzf-key-bindings' "$blerc"
grep -Fq 'bleopt complete_auto_delay=120' "$blerc"
grep -Fq "ble-bind -x 'C-r' __atuin_history" "$keymap"
grep -Fq "ble-bind -x 'C-t' _bash_keymap_files" "$keymap"
grep -Fq "ble-bind -x 'M-c' _bash_keymap_dirs" "$keymap"

printf '%s\n' 'PASS: ble.sh, Atuin y FZF comparten ownership sin colisiones'
