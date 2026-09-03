#!/usr/bin/env bash
set -euo pipefail
# Toggle/crear kitty con glow(SHORTCUTS.md) en scratchpad — cheatsheet de
# atajos i3/tmux/kitty/nvim, mismo patrón que toggle_scratch.sh.

poll_seconds="${I3_SCRATCH_POLL_SECONDS:-0.15}"
[[ "$poll_seconds" =~ ^[0-9]+([.][0-9]+)?$ ]] || poll_seconds=0.15

HAS=$(i3-msg -t get_tree | jq -r '
  .. | objects
  | select(.window_properties? and
           (.window_properties.class=="scratch-shortcuts" or
            .window_properties.instance=="scratch-shortcuts"))
  | .id
' | head -n1)

if [ -n "$HAS" ]; then
  i3-msg '[class="scratch-shortcuts" instance="scratch-shortcuts"] scratchpad show' >/dev/null
  exit 0
fi

kitty --class scratch-shortcuts -e glow ~/dotfiles/SHORTCUTS.md &

for _ in 1 2 3 4 5; do
  sleep "$poll_seconds"
  i3-msg '[class="scratch-shortcuts" instance="scratch-shortcuts"] mark --replace scratch_shortcuts, move to scratchpad' >/dev/null
  if i3-msg -t get_marks | jq -e 'index("scratch_shortcuts") != null' >/dev/null; then
    i3-msg '[con_mark="scratch_shortcuts"] scratchpad show' >/dev/null
    exit 0
  fi
done

i3-msg '[class="scratch-shortcuts" instance="scratch-shortcuts"] move to scratchpad, scratchpad show' >/dev/null
