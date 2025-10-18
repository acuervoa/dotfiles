#!/usr/bin/env bash
# Toggle/crear Obsidian como scratchpad, sin duplicados

MARK="scratch_obs"
CLASS="obsidian"

if i3-msg -t get_marks | grep -qx "$MARK"; then
    i3-msg '[con_mark="scratch_obs"] scratchpad show' >/dev/null
    exit 0
fi

obsidian &

for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 0.2
    i3-msg '[class="obsidian"] mark --add scratch_obs' >/dev/null
    if i3-msg -t get_marks | grep -qx "$MARK"; then
        i3-msg '[con_mark="scratch_obs"] floating enable, move position center, resize set 1600 900, move to scratchpad, scratchpad show' >/dev/null
        exit 0
    fi
done

i3-msg '[class="obsidian"] floating enable, move position center, resize set 1600 900, move to scratchpad, scratchpad show' >/dev/null
