# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Convenciones

- **tmux Prefix:** `Ctrl+s` (añade `stty -ixon` en `~/.bashrc` para liberarlo).
- **NeoVim Leader:** `Espacio` (`<leader>`).
- **i3 $mod:** `Super` (tecla Windows).

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

> Requiere **vim-tmux-navigator** (o mapeos equivalentes) para navegación cruzada `Ctrl+h/j/k/l` entre (Neo)Vim y tmux.

### NeoVim (`config/nvim/lua/keymaps.lua`)

- Navegación ventanas: **Ctrl+h/j/k/l**
- Redimensionar splits: **Ctrl+←/→/↑/↓**
- Guardar: **<leader>w**
- Búsqueda coherente: **Ctrl+f** abre `/`
- Mover línea: **Alt+j / Alt+k** (Normal e Insert)
- Alternativas foco: **Alt+h / Alt+l**

### tmux (`~/.tmux.conf`)

- Foco panes: **Ctrl+h/j/k/l** (sin depender del modo copy)
- Splits: Prefix+`"` (H) / `%` (V)
- Redimensionar: Ctrl+Flechas (±1), Alt+Flechas (±5)
- Zoom: `z`/`Z` · Layout: `Space` · Trees: `w/s/S`
- Buscar ventana: `f`
- Recargar config: `r`/`R`

### Kitty (`config/kitty/kitty.conf`)

- Copiar: **Ctrl+Shift+C** · Pegar: **Ctrl+Shift+V**
- Nueva ventana OS: **Ctrl+Shift+N** · Nueva pestaña: **Ctrl+Shift+Enter**
- URLs: **Ctrl+click** para abrir

### i3 (`config/i3/config`)

- Mod principal: **$mod = Mod4 (Super)**
- Scratchpad (kitty): **$mod+Shift+Return** (toggle)
- Layouts: `$mod+s` stacking · `$mod+w` tabbed · Fullscreen `$mod+z`
- Redimensionar: `$mod+Shift+Flechas`
- Autostart relevante: `redshift -l geoclue2 -t 6500:3600`

### Polybar (`config/polybar/config.ini`)

- **mic**: **click izq** → mute/unmute (`~/.config/dunst/scripts/micctl toggle`)
- **updates**: **click izq** → terminal de actualización; **click der** → `notify-send "Actualizaciones pendientes" "$(checkupdates)"`

### Dunst

- Alternar pausa: `dunstctl set-paused toggle`
- Probar: `notify-send "Test" "Dunst OK"`

### Rofi

- App launcher: `$mod+d` (_drun_) · `$mod+Shift+d` (window) · `$mod+F11` (run) · `$mod+v` (clipmenu)

---

## English

### Conventions

- **tmux Prefix:** `Ctrl+s` (add `stty -ixon` in `~/.bashrc`).
- **NeoVim Leader:** `Space` (`<leader>`).
- **i3 $mod:** `Super` (Windows key).

### Parity matrix (common actions)

| Action                     | tmux                       | i3                         | NeoVim                    | kitty                                              |
| -------------------------- | -------------------------- | -------------------------- | ------------------------- | -------------------------------------------------- |
| Move between panes/windows | **Ctrl+h/j/k/l**           | $mod+Left/Down/Up/Right    | **Ctrl+h/j/k/l**          | —                                                  |
| Splits H / V               | Prefix+`"` (H) / `%` (V)   | $mod+Mod1+h / $mod+Mod1+v  | `<leader>"` / `<leader>%` | —                                                  |
| Resize                     | Ctrl+Arrows (±1), Alt (±5) | $mod+Shift+Arrows          | Ctrl+Arrows               | —                                                  |
| Zoom/Fullscreen            | `z` / `Z`                  | $mod+z                     | `<leader>z`               | —                                                  |
| Save                       | —                          | —                          | `<leader>w`               | —                                                  |
| Search                     | `f` find-window            | —                          | **Ctrl+f** → `/`          | URL: **Ctrl+click**                                |
| New window/tab             | `c` / `,` rename           | $mod+Return (kitty)        | —                         | **Ctrl+Shift+Enter** (tab), **Ctrl+Shift+n** (win) |
| Scratch terminal           | —                          | $mod+Shift+Return (toggle) | —                         | —                                                  |
| Reload config              | `r`/`R` tmux.conf          | $mod+Shift+c (reload i3)   | `:source`                 | —                                                  |
