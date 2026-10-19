# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Atajos por entorno / Shortcuts by environment

#### i3 (stow/i3/.config/i3/config)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| Super+d | exec --no-startup-id ~/.config/i3/scripts/rofi-diagnostic.sh |
| Super+F11 | exec --no-startup-id rofi -show run -fullscreen -font "MesloLGLDZ Nerd Font 10" |
| Super+v | exec --no-startup-id "CM_LAUNCHER=rofi clipmenu" |
| Super+p | exec --no-startup-id rofi-bw |
| Super+g | exec --no-startup-id gtk-launch chatgpt-webapp |
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
| Super+Shift+Return | exec --no-startup-id ~/.config/i3/scripts/toggle_scratch.sh |
| Super+Shift+n | exec --no-startup-id ~/.config/i3/scripts/toggle_scratch_obsidian.sh |
| Super+i | exec --no-startup-id ~/.config/i3/scripts/toggle_scratch_shortcuts.sh |
| Super+Return | exec --no-startup-id $term -e tmux new-session -A -s main |
| Super+h | focus left |
| Super+j | focus down |
| Super+k | focus up |
| Super+l | focus right |
| Super+Tab | workspace back_and_forth |
| Super+Shift+h | move left |
| Super+Shift+j | move down |
| Super+Shift+k | move up |
| Super+Shift+l | move right |
| Super+Shift+space | floating toggle |
| Super+space | focus mode_toggle |
| Super+z | fullscreen toggle |
| Super+f | exec --no-startup-id rofi -show window |
| Super+s | layout stacking |
| Super+w | layout tabbed |
| Super+e | layout toggle split |
| Super+Mod1+h | split h |
| Super+Mod1+v | split v |
| h | resize shrink width 10 px or 10 ppt |
| j | resize grow height 10 px or 10 ppt |
| k | resize shrink height 10 px or 10 ppt |
| l | resize grow width 10 px or 10 ppt |
| q | mode "default" |
| Escape | mode "default" |
| Return | mode "default" |
| Super+r | mode "resize" |
| Super+1 | workspace 1:DEV |
| Super+2 | workspace 2:OPS |
| Super+3 | workspace 3:WEB |
| Super+4 | workspace 4:DOC |
| Super+5 | workspace 5:AI |
| Super+6 | workspace 6:DATA |
| Super+7 | workspace 7:TERM |
| Super+8 | workspace 8:CHAT |
| Super+9 | workspace 9:MEDIA |
| Super+0 | workspace 10:MISC |
| Super+Shift+1 | move container to workspace 1:DEV |
| Super+Shift+2 | move container to workspace 2:OPS |
| Super+Shift+3 | move container to workspace 3:WEB |
| Super+Shift+4 | move container to workspace 4:DOC |
| Super+Shift+5 | move container to workspace 5:AI |
| Super+Shift+6 | move container to workspace 6:DATA |
| Super+Shift+7 | move container to workspace 7:TERM |
| Super+Shift+8 | move container to workspace 8:CHAT |
| Super+Shift+9 | move container to workspace 9:MEDIA |
| Super+Shift+0 | move container to workspace 10:MISC |
| Super+Ctrl+Left | move container to output left |
| Super+Ctrl+Right | move container to output right |
| Super+Shift+c | reload |
| Super+Shift+r | restart |
| Super+Shift+x | exec --no-startup-id ~/.config/i3/scripts/i3lock.sh |
| Super+Shift+e | exec --no-startup-id ~/.config/i3/scripts/session-exit-confirm.sh |
| control+mod1+Delete | exec --no-startup-id ~/.config/i3/scripts/mode_system.sh |
| Super+q | exec --no-startup-id ~/.config/i3/scripts/confirm_kill.sh |
| Super+Shift+y | exec --no-startup-id ~/.config/polybar/scripts/dunst-toggle.sh |
| Super+y | exec --no-startup-id /usr/bin/dunstctl history-pop |
| Super+F2 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh select |
| Super+Shift+F2 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh full |
| Super+Shift+F3 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh save-select |
| Super+Shift+F4 | exec --no-startup-id ~/.config/i3/scripts/screenshot_maim.sh delay 2 select |
Para cambiar el tamaño de la ventana, pulsa `Super+r` para entrar en el modo
`resize`. Dentro del modo, `h` reduce el ancho, `l` lo aumenta, `j` aumenta la
altura y `k` la reduce. Pulsa `q`, `Escape` o `Enter` para volver al modo normal.

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
