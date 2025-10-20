# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Convenciones

- **tmux Prefix:** `Ctrl+s` (añade `stty -ixon` en `~/.bashrc` para liberarlo).
- **NeoVim Leader:** `Space` (`<leader>`).
- **$mod i3:** `Super` (tecla Windows).

### Matriz de paridad (acciones comunes)

| Acción                | tmux                                | i3                         | NeoVim                            | kitty                                              |
| --------------------- | ----------------------------------- | -------------------------- | --------------------------------- | -------------------------------------------------- |
| Mover foco ← ↓ ↑ →    | **Ctrl+h/j/k/l** (siempre)          | $mod+Left/Down/Up/Right    | **Ctrl+h/j/k/l**                  | —                                                  |
| Splits H / V          | Prefix+`"` (H) / `%` (V)            | $mod+Mod1+h / $mod+Mod1+v  | `<leader>"` (H) / `<leader>%` (V) | —                                                  |
| Redimensionar         | Ctrl+Flechas (±1), Alt+Flechas (±5) | $mod+Shift+Flechas         | Ctrl+Flechas                      | —                                                  |
| Zoom/Fullscreen       | `z` / `Z`                           | $mod+z                     | `<leader>z` (si mapeado)          | —                                                  |
| Guardar               | —                                   | —                          | `<leader>w`                       | —                                                  |
| Búsqueda              | `f` find-window                     | —                          | **Ctrl+f** abre `/`               | URL: **Ctrl+click**                                |
| Nueva ventana/pestaña | `c` / `,` rename                    | $mod+Return (kitty)        | —                                 | **Ctrl+Shift+Enter** (tab), **Ctrl+Shift+n** (win) |
| Scratch terminal      | —                                   | $mod+Shift+Return (toggle) | —                                 | —                                                  |
| Reload config         | `r`/`R` tmux.conf                   | $mod+Shift+c (reload i3)   | `:source` (o autocomandos)        | —                                                  |

> **Prefix tmux:** `Ctrl+s` (requiere `stty -ixon`). **Leader NeoVim:** Espacio.

> Esta tabla refleja **lo confirmado en los configs actuales** (NeoVim, kitty, i3) y la **intención de paridad** donde tmux/i3 no muestran binding explícito aquí. Revisa cada sección.

### NeoVim (`config/nvim/lua/keymaps.lua`)

- Navegación ventanas: **Ctrl+h/j/k/l**
- Alternativas: **Alt+h**, **Alt+l**
- Mover línea (VSCode-like): **Alt+j / Alt+k** (Normal e Insert)
- Redimensionar splits: **Ctrl+←/→/↑/↓**
- Guardar: **<leader>w**
- Búsqueda coherente: **Ctrl+f** abre el prompt `/`

### Kitty (`config/kitty/kitty.conf`)

- Copiar: **Ctrl+Shift+C**
- Pegar: **Ctrl+Shift+V**
- Nueva ventana OS: **Ctrl+Shift+N**
- Nueva pestaña: **Ctrl+Shift+Enter**
- (Si está configurado) **Ctrl+click** sobre URL para abrirla

### i3 (`config/i3/config`)

- Mod principal: **$mod = Mod4 (Super)**
- Scratchpad (terminal): **$mod+Shift+Return** → `~/.config/i3/scripts/toggle_scratch.sh`
- Brillo: **XF86MonBrightnessUp/Down** con `brightnessctl`
- Autostart relevante: `redshift -l geoclue2 -t 6500:3600`

### Polybar (`config/polybar/config.ini`)

- **mic**: **click-izq** → _mute/unmute_ (`~/.config/dunst/scripts/micctl toggle`)
- **updates**: **click-izq** → abre terminal de actualización; **click-der** → `notify-send "Actualizaciones pendientes" "$(checkupdates)"`

### Dunst

- Alternar pausa: `dunstctl set-paused toggle`
- Probar: `notify-send "Test" "Dunst OK"`

---

## English

### Conventions

- **tmux Prefix:** `Ctrl+s` (add `stty -ixon` in `~/.bashrc`).
- **NeoVim Leader:** `Space` (`<leader>`).
- **i3 $mod:** `Super` (Windows key).

### Parity matrix (common actions)

| Action                     | tmux                       | i3                             | NeoVim               | kitty |
| -------------------------- | -------------------------- | ------------------------------ | -------------------- | ----- |
| Move between panes/windows | _(per your tmux binds)_    | _(per i3/config)_              | **Ctrl+h/j/k/l**     | —     |
| Save                       | —                          | —                              | **<leader>w**        | —     |
| Search                     | —                          | —                              | **Ctrl+f** opens `/` | —     |
| Resize                     | _(typical: Prefix+arrows)_ | _(per i3/config)_              | **Ctrl+←/→/↑/↓**     | —     |
| Scratch terminal           | —                          | **$mod+Shift+Return (toggle)** | —                    | —     |

> This matrix shows what’s **confirmed in current configs** (NeoVim, kitty, i3) and the **parity intent** where tmux/i3 bindings aren’t explicit here. See sections below.

### NeoVim (`config/nvim/lua/keymaps.lua`)

- Window navigation: **Ctrl+h/j/k/l**
- Alternatives: **Alt+h**, **Alt+l**
- Move line (VSCode-like): **Alt+j / Alt+k** (Normal & Insert)
- Resize splits: **Ctrl+←/→/↑/↓**
- Save: **<leader>w**
- Search: **Ctrl+f** opens `/`

### Kitty (`config/kitty/kitty.conf`)

- Copy: **Ctrl+Shift+C**
- Paste: **Ctrl+Shift+V**
- New OS window: **Ctrl+Shift+N**
- New tab: **Ctrl+Shift+Enter**
- (If configured) **Ctrl+click** on URL to open

### i3 (`config/i3/config`)

- Main modifier: **$mod = Mod4 (Super)**
- Scratchpad (terminal): **$mod+Shift+Return** → `~/.config/i3/scripts/toggle_scratch.sh`
- Brightness: **XF86MonBrightnessUp/Down** with `brightnessctl`
- Relevant autostart: `redshift -l geoclue2 -t 6500:3600`

### Polybar (`config/polybar/config.ini`)

- **mic**: **left click** → _mute/unmute_ (`~/.config/dunst/scripts/micctl toggle`)
- **updates**: **left click** → open update terminal; **right click** → `notify-send "Actualizaciones pendientes" "$(checkupdates)"`

### Dunst

- Toggle pause: `dunstctl set-paused toggle`
- Test: `notify-send "Test" "Dunst OK"`

# Glosario de atajos — Entorno Arch (i3/tmux/Neovim/Kitty/Polybar/Dunst/Picom/Rofi)

**Leyenda**  
• `Ctrl`=Control · `Alt`=Alt · `Mayús`=Shift · **Leader (Neovim)**=Espacio.  
• **tmux/root** = sin prefijo · **tmux/prefix** = tras `Ctrl-s` (prefijo).  
• `$mod` = modificador i3 (p.ej. Super).

| Categoría                | Acción                                     | Neovim              | tmux / root (sin prefijo)                                          | tmux / prefix (Ctrl-s + …)                                                                                  | i3                                                                                                                                                         | Kitty                                                      | Rofi                                                               | Polybar                                                                                  | Dunst                                  | Picom |
| ------------------------ | ------------------------------------------ | ------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | -------------------------------------- | ----- | --- |
| **Foco / Navegación**    | Mover foco ← ↓ ↑ →                         | Ctrl-h/j/k/l        | Ctrl-h/j/k/l **smart** (si Vim/fzf, lo envía dentro) · Alt-h/j/k/l | h/j/k/l, Left/Down/Up/Right                                                                                 | $mod+$left,$down,$up,$right y $mod+Left/Down/Up/Right                                                                                                      | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
|                          | Último panel/ventana                       | —                   | —                                                                  | `;` último pane, `a` última ventana                                                                         | $mod+Tab back_and_forth                                                                                                                                    | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Splits / Layout**      | Split H / V                                | Leader+" / Leader+% | —                                                                  | `"` vertical (-v), `%` horizontal (-h)                                                                      | $mod+Mod1+h (split h), $mod+Mod1+v (split v), $mod+e (toggle)                                                                                              | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
|                          | Layouts / Zoom                             | —                   | F10 sync-panes toggle                                              | `Space` next-layout · `M-1..M-7` layouts · `z/Z` zoom                                                       | $mod+s stacking · $mod+w tabbed · $mod+z fullscreen                                                                                                        | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Resize**               | Resize fino                                | Ctrl+←/→/↑/↓        | Alt+Shift+Left/Right ±5 · Alt+Shift+Up/Down ±2                     | Ctrl+Arrows ±1 · Alt+Arrows ±5 · M-Arrows ±5                                                                | $mod+Shift+Left/Right/Up/Down (±10 px/pp)                                                                                                                  | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Mover**                | Mover/swap                                 | —                   | —                                                                  | `{` ↑, `}` ↓ (swap panes)                                                                                   | $mod+Shift+Left/Down/Up/Right                                                                                                                              | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Ventanas / WS**        | Nueva / cambiar / renombrar                | —                   | M-Left/Right prev/next                                             | `c` nueva, `n/p` next/prev, `,` rename, `.` mover, `0..9` seleccionar, `L` last-client                      | $mod+1..0 ir WS; $mod+Shift+1..0 mover a WS                                                                                                                | Ctrl+Shift+Enter nueva pestaña; Ctrl+Shift+n nueva ventana | —                                                                  | —                                                                                        | —                                      | —     | —   |
| **Buffers / Copiado**    | Copiar/pegar                               | —                   | WheelUpStatus prev win · WheelDownStatus next win                  | `[` copy-mode · `]` paste · `=` choose-buffer · `#` list-buffers · `-` delete-buffer · `PPage` copy-mode -u | —                                                                                                                                                          | Ctrl+Shift+c / v                                           | —                                                                  | —                                                                                        | —                                      | —     |
| **Búsqueda**             | Buscar / ayuda                             | Ctrl-f              | —                                                                  | `f` find-window · `?` list-keys · `/` ayuda keys                                                            | —                                                                                                                                                          | Ctrl+click URL                                             | $mod+d drun · $mod+F11 run · $mod+Shift+d window · $mod+v clipmenu | —                                                                                        | —                                      | —     |
| **Pane / Gestión**       | Kill / detach / clock                      | —                   | —                                                                  | `q` kill-pane · `BSpace` kill-otros panes · `&` kill-window · `d` detach · `t` clock                        | $mod+q kill                                                                                                                                                | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Recarga / Menús**      | Reload / menús                             | —                   | —                                                                  | `r/R` recargar tmux.conf · `\` menús · `w/s/S` trees/sessionx                                               | $mod+Shift+c reload · $mod+Shift+r restart · $mod+Shift+e salir                                                                                            | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Plugins tmux**         | TPM / fzf / extrakto / yank / resurrect    | —                   | —                                                                  | `I/U/M-u` TPM · `F` tmux-fzf · `x` extrakto · `y/Y` yank · `C-s` save resurrect · `C-r` restore             | —                                                                                                                                                          | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |
| **Audio / Multimedia**   | Volumen / Mic / Player                     | —                   | —                                                                  | —                                                                                                           | XF86Audio\* → `$volscript` y `$micscript`; Play/Pause/Next/Prev con `playerctl`                                                                            | —                                                          | —                                                                  | **Click izq. mic** toggle (`micctl`)                                                     | —                                      | —     |
| **Dunst**                | Mostrar / Toggle                           | —                   | —                                                                  | —                                                                                                           | $mod+y `dunstctl history-pop` · $mod+Shift+y toggle (script)                                                                                               | —                                                          | —                                                                  | **Click izq.** toggle dunst                                                              | `dmenu` definido; incluye `mocha.conf` | —     |
| **Sistema / Utilidades** | Terminal / scratch / screenshots / outputs | —                   | —                                                                  | —                                                                                                           | $mod+Return kitty · $mod+Shift+Return scratch · $mod+Shift+n scratch Obsidian · $mod+F2 fullshot · $mod+Shift+F2 GUI · $mod+Ctrl+Left/Right mover a salida | —                                                          | —                                                                  | **Click izq.** actualizador (abre kitty script) · **Click der.** notifica `checkupdates` | —                                      | —     |
| **Brillo**               | Subir/Bajar                                | —                   | —                                                                  | —                                                                                                           | XF86MonBrightnessUp/Down → `brightnessctl`                                                                                                                 | —                                                          | —                                                                  | —                                                                                        | —                                      | —     |

**Neovim extra (edición)**  
• Mover línea: `Alt-j` (↓), `Alt-k` (↑) · Duplicar: `Shift+Alt-j/k`  
• Cerrar ventana: `<leader>q` · Cerrar otras: `<leader><BS>` · Selector buffers: `<leader>s`
