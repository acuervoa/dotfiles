# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Atajos por entorno / Shortcuts by environment

[34m[INFO][0m Parsing i3 config: /home/acuervo/dotfiles/stow/i3/.config/i3/config
#### i3 (stow/i3/.config/i3/config)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| $mod+d | exec --no-startup-id rofi -modi run -show drun -show-icons -font "Noto Sans 13" |
| $mod+F11 | exec --no-startup-id rofi -show run -fullscreen -font "Noto Sans 13" |
| $mod+Shift+d | exec --no-startup-id rofi -show window -show-icons -font "Noto Sans 13" |
| $mod+v | exec --no-startup-id "CM_LAUNCHER=rofi clipmenu" |
| XF86MonBrightnessUp | exec --no-startup-id brightnessctl set +5% |
| XF86MonBrightnessDown | exec --no-startup-id brightnessctl set 5%- |
| XF86AudioRaiseVolume | exec --no-startup-id $volscript up && $refresh_polybar |
| XF86AudioLowerVolume | exec --no-startup-id $volscript down && $refresh_polybar |
| XF86AudioMute |        exec --no-startup-id $volscript mute && $refresh_polybar |
| XF86AudioMicMute |     exec --no-startup-id $micscript toggle && $refresh_polybar |
| Shift+XF86AudioRaiseVolume | exec --no-startup-id $micscript up && $refresh_polybar |
| Shift+XF86AudioLowerVolume | exec --no-startup-id $micscript down && $refresh_polybar |
| XF86AudioPlay | exec playerctl play |
| XF86AudioPause | exec playerctl pause |
| XF86AudioNext | exec playerctl next |
| XF86AudioPrev | exec playerctl previous |
| $mod+Shift+Return | exec --no-startup-id ~/.config/i3/scripts/toggle_scratch.sh |
| $mod+Shift+n | exec --no-startup-id ~/.config/i3/scripts/toggle_scratch_obsidian.sh |
| $mod+Return | exec --no-startup-id kitty |
| $mod+$left | focus left |
| $mod+$down | focus down |
| $mod+$up | focus up |
| $mod+$right | focus right |
| $mod+Tab | workspace back_and_forth |
| $mod+Left | focus left |
| $mod+Down | focus down |
| $mod+Up | focus up |
| $mod+Right | focus right |
| $mod+Shift+$left | move left |
| $mod+Shift+$down | move down |
| $mod+Shift+$up | move up |
| $mod+Shift+$right | move right |
| $mod+Shift+space | floating toggle |
| $mod+space | focus mode_toggle |
| $mod+z | fullscreen toggle |
| $mod+f | exec --no-startup-id rofi -show window |
| $mod+s | layout stacking |
| $mod+w | layout tabbed |
| $mod+e | layout toggle split |
| $mod+Mod1+h | split h |
| $mod+Mod1+v | split v |
| $mod+Shift+Left |  resize shrink width 10 px or 10 ppt |
| $mod+Shift+Right | resize grow   width 10 px or 10 ppt |
| $mod+Shift+Up |    resize grow   height 10 px or 10 ppt |
| $mod+Shift+Down |  resize shrink height 10 px or 10 ppt |
| $mod+1 | workspace $ws1 |
| $mod+2 | workspace $ws2 |
| $mod+3 | workspace $ws3 |
| $mod+4 | workspace $ws4 |
| $mod+5 | workspace $ws5 |
| $mod+6 | workspace $ws6 |
| $mod+7 | workspace $ws7 |
| $mod+8 | workspace $ws8 |
| $mod+9 | workspace $ws9 |
| $mod+0 | workspace $ws10 |
| $mod+Shift+1 | move container to workspace $ws1 |
| $mod+Shift+2 | move container to workspace $ws2 |
| $mod+Shift+3 | move container to workspace $ws3 |
| $mod+Shift+4 | move container to workspace $ws4 |
| $mod+Shift+5 | move container to workspace $ws5 |
| $mod+Shift+6 | move container to workspace $ws6 |
| $mod+Shift+7 | move container to workspace $ws7 |
| $mod+Shift+8 | move container to workspace $ws8 |
| $mod+Shift+9 | move container to workspace $ws9 |
| $mod+Shift+0 | move container to workspace $ws10 |
| $mod+Ctrl+Left | move container to output left |
| $mod+Ctrl+Right | move container to output right |
| $mod+Shift+c | reload |
| $mod+Shift+r | restart |
| $mod+Shift+e | exec "i3-nagbar -t warning -m '¿Quieres salir de i3?' -B 'Sí, salir' 'i3-msg exit'" |
| control+mod1+Delete | exec --no-startup-id ~/.config/i3/scripts/mode_system.sh |
| $mod+q | kill |
| $mod+Shift+y | exec --no-startup-id ~/.config/polybar/scripts/dunst-toggle.sh |
| $mod+y | exec --no-startup-id /usr/bin/dunstctl history-pop |
| $mod+F2 | exec --no-startup-id flameshot full -p ~/Pictures |
| $mod+Shift+F2 | exec --no-startup-id flameshot gui -c |

[34m[INFO][0m Parsing tmux config: /home/acuervo/dotfiles/stow/tmux/.tmux.conf
#### tmux (stow/tmux/.tmux.conf)

| Atajo / Shortcut | Descripción / Action |
| ---------------- | -------------------- |
| -n C-f | copycat-file |
| -n C-u | copycat-url |
| -n C-d | copycat-dir |
| -n M-S-Left |  resize-pane -L 5 |
| -n M-S-Right | resize-pane -R 5 |
| -n M-S-Up |    resize-pane -U 2 |
| -n M-S-Down |  resize-pane -D 2 |
| -n M-Left |  previous-window |
| -n M-Right | next-window |
| -n C-PageDown | next-window |
| -n C-PageUp |   previous-window |
| -n C-h | if-shell "$is_vim" 'send-keys C-h' 'select-pane -L' |
| -n C-j | if-shell "$is_vim" 'send-keys C-j' 'select-pane -D' |
| -n C-k | if-shell "$is_vim" 'send-keys C-k' 'select-pane -U' |
| -n C-l | if-shell "$is_vim" 'send-keys C-l' 'select-pane -R' |
| -n F10 | setw synchronize-panes \; display "🔗 Sync: #{?pane_synchronized,on,off}" |

[34m[INFO][0m Parsing kitty config: /home/acuervo/dotfiles/stow/kitty/.config/kitty/kitty.conf
#### Kitty (stow/kitty/.config/kitty/kitty.conf)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| ctrl+left press | ungrabbed,grabbed mouse_click_url # open URL on simple click. Otherwise, press Ctrl + Shift and then click. |
| ctrl+shift+c copy_to_clipboard |  |
| ctrl+shift+v paste_from_clipboard |  |
| ctrl+shift+n new_os_window |  |
| ctrl+shift+enter new_tab |  |
| alt+h send_text | all \x1bh |
| alt+j send_text | all \x1bj |
| alt+k send_text | all \x1bk |
| alt+l send_text | all \x1bl |
| alt+left send_text | all \x1b[1;3D |
| alt+right send_text | all \x1b[1;3C |
| alt+up send_text | all \x1b[1;3A |
| alt+down send_text | all \x1b[1;3B |

[34m[INFO][0m Parsing NeoVim keymaps: /home/acuervo/dotfiles/stow/nvim/.config/nvim/lua/config/keymaps.lua
#### NeoVim (stow/nvim/.config/nvim/lua/config/keymaps.lua)

| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |
