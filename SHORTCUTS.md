# Glosario de atajos — Entorno Arch (i3/tmux/Neovim/Kitty/Polybar/Dunst/Picom/Rofi)

**Leyenda**  
• `Ctrl`=Control · `Alt`=Alt · `Mayús`=Shift · **Leader (Neovim)**=Espacio.  
• **tmux/root** = sin prefijo · **tmux/prefix** = tras `Ctrl-s` (prefijo).  
• `$mod` = modificador i3 (p.ej. Super).

| Categoría | Acción | Neovim | tmux / root (sin prefijo) | tmux / prefix (Ctrl-s + …) | i3 | Kitty | Rofi | Polybar | Dunst | Picom |
|---|---|---|---|---|---|---|---|---|---|---|
| **Foco / Navegación** | Mover foco ← ↓ ↑ → | Ctrl-h/j/k/l | Ctrl-h/j/k/l **smart** (si Vim/fzf, lo envía dentro) · Alt-h/j/k/l | h/j/k/l, Left/Down/Up/Right | $mod+$left,$down,$up,$right y $mod+Left/Down/Up/Right | — | — | — | — | — |
| | Último panel/ventana | — | — | `;` último pane, `a` última ventana | $mod+Tab back_and_forth | — | — | — | — | — |
| **Splits / Layout** | Split H / V | Leader+" / Leader+% | — | `"` vertical (-v), `%` horizontal (-h) | $mod+Mod1+h (split h), $mod+Mod1+v (split v), $mod+e (toggle) | — | — | — | — | — |
| | Layouts / Zoom | — | F10 sync-panes toggle | `Space` next-layout · `M-1..M-7` layouts · `z/Z` zoom | $mod+s stacking · $mod+w tabbed · $mod+z fullscreen | — | — | — | — | — |
| **Resize** | Resize fino | Ctrl+←/→/↑/↓ | Alt+Shift+Left/Right ±5 · Alt+Shift+Up/Down ±2 | Ctrl+Arrows ±1 · Alt+Arrows ±5 · M-Arrows ±5 | $mod+Shift+Left/Right/Up/Down (±10 px/pp) | — | — | — | — | — |
| **Mover** | Mover/swap | — | — | `{` ↑, `}` ↓ (swap panes) | $mod+Shift+Left/Down/Up/Right | — | — | — | — | — |
| **Ventanas / WS** | Nueva / cambiar / renombrar | — | M-Left/Right prev/next | `c` nueva, `n/p` next/prev, `,` rename, `.` mover, `0..9` seleccionar, `L` last-client | $mod+1..0 ir WS; $mod+Shift+1..0 mover a WS | Ctrl+Shift+Enter nueva pestaña; Ctrl+Shift+n nueva ventana | — | — | — | — | — |
| **Buffers / Copiado** | Copiar/pegar | — | WheelUpStatus prev win · WheelDownStatus next win | `[` copy-mode · `]` paste · `=` choose-buffer · `#` list-buffers · `-` delete-buffer · `PPage` copy-mode -u | — | Ctrl+Shift+c / v | — | — | — | — |
| **Búsqueda** | Buscar / ayuda | Ctrl-f | — | `f` find-window · `?` list-keys · `/` ayuda keys | — | Ctrl+click URL | $mod+d drun · $mod+F11 run · $mod+Shift+d window · $mod+v clipmenu | — | — | — |
| **Pane / Gestión** | Kill / detach / clock | — | — | `q` kill-pane · `BSpace` kill-otros panes · `&` kill-window · `d` detach · `t` clock | $mod+q kill | — | — | — | — | — |
| **Recarga / Menús** | Reload / menús | — | — | `r/R` recargar tmux.conf · `\` menús · `w/s/S` trees/sessionx | $mod+Shift+c reload · $mod+Shift+r restart · $mod+Shift+e salir | — | — | — | — | — |
| **Plugins tmux** | TPM / fzf / extrakto / yank / resurrect | — | — | `I/U/M-u` TPM · `F` tmux-fzf · `x` extrakto · `y/Y` yank · `C-s` save resurrect · `C-r` restore | — | — | — | — | — | — |
| **Audio / Multimedia** | Volumen / Mic / Player | — | — | — | XF86Audio* → `$volscript` y `$micscript`; Play/Pause/Next/Prev con `playerctl` | — | — | **Click izq. mic** toggle (`micctl`) | — | — |
| **Dunst** | Mostrar / Toggle | — | — | — | $mod+y `dunstctl history-pop` · $mod+Shift+y toggle (script) | — | — | **Click izq.** toggle dunst | `dmenu` definido; incluye `mocha.conf` | — |
| **Sistema / Utilidades** | Terminal / scratch / screenshots / outputs | — | — | — | $mod+Return kitty · $mod+Shift+Return scratch · $mod+Shift+n scratch Obsidian · $mod+F2 fullshot · $mod+Shift+F2 GUI · $mod+Ctrl+Left/Right mover a salida | — | — | **Click izq.** actualizador (abre kitty script) · **Click der.** notifica `checkupdates` | — | — |
| **Brillo** | Subir/Bajar | — | — | — | XF86MonBrightnessUp/Down → `brightnessctl` | — | — | — | — | — |

**Neovim extra (edición)**  
• Mover línea: `Alt-j` (↓), `Alt-k` (↑) · Duplicar: `Shift+Alt-j/k` · Guardar: `Leader+w` · Cerrar ventana: `Leader+q` · Cerrar otras: `Leader+Backspace` · Selector de buffers: `Leader+s`.

