#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kitty_config="$repo_root/stow/kitty/.config/kitty/kitty.conf"
tmux_config="$repo_root/stow/tmux/.tmux.conf"
i3_config="$repo_root/stow/i3/.config/i3/config"
polybar_config="$repo_root/stow/polybar/.config/polybar/config.ini"
dunst_config="$repo_root/stow/dunst/.config/dunst/dunstrc"

for file in "$kitty_config" "$tmux_config" "$i3_config" "$polybar_config" "$dunst_config"; do
  test -f "$file"
done

# Transporte: Kitty carries terminal input/clipboard; tmux owns multiplexing.
grep -Fq 'shell /usr/bin/bash' "$kitty_config"
grep -Fq 'env TERM xterm-kitty' "$kitty_config"
grep -Fq 'map ctrl+shift+c copy_to_clipboard' "$kitty_config"
grep -Fq 'map ctrl+shift+v paste_from_clipboard' "$kitty_config"
grep -Fq 'set -g prefix C-s' "$tmux_config"
grep -Fq 'set -g set-clipboard on' "$tmux_config"

# Navigation: i3 owns workspaces, tmux owns panes, and their key families stay
# distinct from Kitty's transport maps.
grep -Fq 'bindsym $mod+r mode "resize"' "$i3_config"
grep -Fq 'bind-key -n C-h' "$tmux_config"
grep -Fq 'bind-key -n C-j' "$tmux_config"
grep -Fq 'bind-key -n C-k' "$tmux_config"
grep -Fq 'bind-key -n C-l' "$tmux_config"
! grep -Eq '^map (ctrl|control)\+(h|j|k|l|s) ' "$kitty_config"

# Feedback: Polybar exposes persistent desktop state; Dunst follows keyboard
# focus and retains a bounded history for keyboard retrieval.
grep -Fq 'modules-right = dunst' "$polybar_config"
grep -Fq 'follow = keyboard' "$dunst_config"
grep -Fq 'sticky_history = yes' "$dunst_config"
grep -Fq 'history_length = 40' "$dunst_config"

printf '%s\n' 'PASS: Kitty/tmux/i3 transport and Polybar/Dunst feedback contract'
