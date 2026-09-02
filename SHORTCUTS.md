# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Atajos por entorno / Shortcuts by environment

#### i3 (stow/i3/.config/i3/config)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| $mod+d | exec --no-startup-id rofi -modi run -show drun -show-icons -font "MesloLGLDZ Nerd Font 10" |
| $mod+F11 | exec --no-startup-id rofi -show run -fullscreen -font "MesloLGLDZ Nerd Font 10" |
| $mod+v | exec --no-startup-id "CM_LAUNCHER=rofi clipmenu" |
| $mod+g | exec --no-startup-id gtk-launch chatgpt-webapp |
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
| $mod+Return | exec --no-startup-id $term -e tmux new-session -A -s main |
| $mod+$left | focus left |
| $mod+$down | focus down |
| $mod+$up | focus up |
| $mod+$right | focus right |
| $mod+Tab | workspace back_and_forth |
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
| h | resize shrink width 10 px or 10 ppt |
| j | resize grow height 10 px or 10 ppt |
| k | resize shrink height 10 px or 10 ppt |
| l | resize grow width 10 px or 10 ppt |
| q | mode "default" |
| Escape | mode "default" |
| Return | mode "default" |
| $mod+r | mode "resize" |
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
| $mod+Shift+x | exec --no-startup-id ~/.config/i3/scripts/i3lock.sh |
| $mod+Shift+e | exec "i3-nagbar -t warning -m '¿Quieres salir de i3?' -B 'Sí, salir' 'i3-msg exit'" |
| control+mod1+Delete | exec --no-startup-id ~/.config/i3/scripts/mode_system.sh |
| $mod+q | exec --no-startup-id ~/.config/i3/scripts/confirm_kill.sh |
| $mod+Shift+y | exec --no-startup-id ~/.config/polybar/scripts/dunst-toggle.sh |
| $mod+y | exec --no-startup-id /usr/bin/dunstctl history-pop |
| $mod+F2 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh select |
| $mod+Shift+F2 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh full |
| $mod+Shift+F3 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh save-select |
| $mod+Shift+F4 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh delay 2 select |

#### tmux (stow/tmux/.tmux.conf)

| Atajo / Shortcut | Descripción / Action |
| ---------------- | -------------------- |
| `C-s h/j/k/l` | Mover foco entre panes |
| `C-s H/J/K/L` | Redimensionar pane |
| `C-s d/r` | Split abajo / derecha |
| `C-s z` | Alternar zoom del pane |
| `C-s p` | Mostrar números de panes |
| `C-s q` | Cerrar pane con confirmación |
| `C-s c` | Nueva ventana |
| `C-s n/N` | Ventana siguiente / anterior |
| `C-s a` | Última ventana |
| `C-s ,` | Renombrar ventana |
| `C-s </>` | Mover ventana |
| `C-s s/S` | Selector de sesiones / proyectos |
| `C-s $` | Renombrar sesión |
| `C-s g/b` | Popups de lazygit / btop |
| `C-s x` | Extrakto |
| `C-s C-p/C-w/C-b` | fzf: panes / ventanas / buffers |
| `C-s m` | Menú tmux-menus |
| `C-s u/U` | Resurrect: guardar / restaurar |
| `C-s R` | Recargar configuración |
| `C-s ?` | Abrir cheatsheet |
Atajos secundarios o de compatibilidad:

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

#### NeoVim (stow/nvim/.config/nvim/lua/config/keymaps.lua)

| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |

## Gramática coordinada y owners

| Contexto | Owner | Regla muscular |
|----------|-------|----------------|
| i3 | i3 | `$mod` cambia workspace o lanza una aplicación |
| Kitty | Kitty | Transporte de terminal, clipboard y secuencias Alt |
| tmux | tmux | `C-s` + acción gestiona panes, ventanas y sesiones |
| Bash/ble.sh | Bash/ble.sh | Comandos y edición de línea; `C-r` consulta Atuin |
| Neovim | Neovim | `<leader>` + grupo gestiona código, tareas y revisión |
| Rofi | Rofi | Selector visual: elegir, `Enter` aceptar, `Escape` cancelar |
| clipmenu | clipmenu | Historial de clipboard; Kitty/tmux sólo transportan |
| Feedback | Polybar/Dunst | Estado persistente en Polybar, eventos en Dunst |
| Proyecto | `tproj`/`dev` | Contexto tmux; LazyGit, Yazi y lnav son herramientas de trabajo |

### Secuencias de memoria muscular

1. Proyecto: `tproj` o `dev` → tmux conserva contexto → Neovim edita.
2. Navegación: `C-h/j/k/l` mueve foco en tmux/Neovim; `$mod` cambia workspace.
3. Validación: `<leader>pt/pT`, `<leader>pf/pl` ejecutan test, formato y lint.
4. Revisión: `lg`, `C-s g` o `<leader>gg` abren LazyGit en su contexto.
5. Observabilidad: `dlogs`/`lnav` inspeccionan logs y `C-s b` abre btop.
6. Cierre: `Escape` cancela selectores; `C-s q` cierra un pane con confirmación.

Las teclas `p/r/y/n/z` conservan su semántica nativa dentro de Vim; en Bash
son comandos o wrappers (`p` para PHP, `r` para repetir, `y` para Yazi,
`n/z` según el catálogo). El contexto decide la acción: no se redefinen las
teclas de movimiento o edición del editor para imitar Bash.
