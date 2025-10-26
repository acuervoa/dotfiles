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

> **Prefix tmux:** `Ctrl+s` (requiere `stty -ixon`). **Leader NeoVim:** Espacio.  
> Esta tabla refleja **configs actuales** y la **intención de paridad**. Revisa las secciones por app si ajustas algo.

---

### NeoVim (`config/nvim/lua/keymaps.lua`)

- Navegación ventanas: **Ctrl+h/j/k/l**
- Redimensionar splits: **Ctrl+←/→/↑/↓**
- Guardar: **<leader>w**
- Búsqueda coherente: **Ctrl+f** abre `/`
- Mover línea: **Alt+j / Alt+k** (Normal e Insert)
- Alternativas foco: **Alt+h / Alt+l**

### tmux (`~/.tmux.conf` o equivalente)

- Foco panes: **Ctrl+h/j/k/l** (sin depender del modo copy)
- Splits: Prefix+`"` (H) / `%` (V)
- Redimensionar: Ctrl+Flechas (±1), Alt+Flechas (±5)
- Zoom: `z`/`Z` · Cambiar layout: `Space` · Siguientes layouts: `M-1..7`
- Buscar ventana: `f` · Árbol sesiones/ventanas: `w/s/S`
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
- **updates**: **click izq** → abre terminal de actualización; **click der** → `notify-send "Actualizaciones pendientes" "$(checkupdates)"`

### Dunst

- Alternar pausa: `dunstctl set-paused toggle`
- Probar: `notify-send "Test" "Dunst OK"`

### Rofi

- App launcher: `$mod+d` (_drun_) · `$mod+Shift+d` (window) · `$mod+F11` (run) · `$mod+v` (clipmenu)

---

## CLI helpers (desde `~/.bash_functions`)

> **Idea:** atajos “de teclado ampliados” a nivel de shell con FZF/TUI, para navegar, buscar y operar más rápido.

### Navegación & búsqueda

| Acción                         | Función  | Ejemplo    | Notas                                               |
| ------------------------------ | -------- | ---------- | --------------------------------------------------- |
| Buscar archivo/dir y abrir     | `fo`     | `fo`       | Previews con `bat`/`eza`; si es dir → `cd` o editar |
| Saltar a dir reciente (zoxide) | `cdf`    | `cdf`      | `zoxide query -l` + preview                         |
| Buscar texto y abrir al match  | `rgf`    | `rgf TODO` | `ripgrep` + salto a línea en `$EDITOR`              |
| Ir a raíz del repo             | `grt`    | `grt`      | `git rev-parse --show-toplevel`                     |
| Fichero tocado recientemente   | `recent` | `recent`   | Según commits últimos 3 días                        |
| Historial con confirmación     | `fhist`  | `fhist`    | Confirmación antes de `eval`                        |

### Git de alto nivel

| Acción                            | Función      | Ejemplo                  | Notas                          |
| --------------------------------- | ------------ | ------------------------ | ------------------------------ |
| Cambiar rama con log preview      | `gcof`       | `gcof`                   | Solo ramas locales             |
| Cambiar/crear rama (local/remota) | `gbr`        | `gbr`                    | Unifica checkout local/remoto  |
| Ver staged bonito                 | `gstaged`    | `gstaged`                | `git diff --cached` → `bat`    |
| Deshacer último commit (soft)     | `gundo`      | `gundo`                  | Conserva working tree          |
| Limpiar ramas mergeadas           | `gclean`     | `gclean`                 | Contra `main/master`           |
| Guardar checkpoint (stash -m)     | `checkpoint` | `checkpoint "WIP login"` | Muestra `stash list`           |
| WIP rápido                        | `wip`        | `wip`                    | `git add -A && commit`         |
| Fixup contra HEAD                 | `fixup`      | `fixup`                  | Luego `rebase -i --autosquash` |
| Watch de cambios en vivo          | `watchdiff`  | `watchdiff`              | Status + diff cada 2s          |

### Docker

| Acción                    | Función | Ejemplo | Notas                                        |
| ------------------------- | ------- | ------- | -------------------------------------------- |
| Servicios activos         | `docps` | `docps` | Detecta `docker-compose` vs `docker compose` |
| Logs `-f` del servicio    | `dlogs` | `dlogs` | Selección con FZF                            |
| Shell dentro del servicio | `dsh`   | `dsh`   | `bash` o `sh`                                |

### Sistema / Utilidades

| Acción                          | Función   | Ejemplo                            | Notas                                   |
| ------------------------------- | --------- | ---------------------------------- | --------------------------------------- |
| Matar procesos con confirmación | `fkill`   | `fkill`                            | SIGTERM → opcional SIGKILL              |
| Copiar al portapapeles          | `cb`      | `echo foo \| cb` · `cb "foo"`      | Wayland: `wl-copy`; X11: `xclip`        |
| Medir tiempo de un comando      | `bench`   | `bench make -j8`                   | ms + s (usa `bc` o `awk`)               |
| Puertos en escucha              | `ports`   | `ports`                            | `ss` o `lsof`                           |
| Repetir último comando fallido  | `redo`    | (tras fallo) `redo`                | Usa `fc`                                |
| Mini TODO en plano              | `todo`    | `todo "Revisar hooks"`             | Persiste en `~/.todo.cli.txt`           |
| Crear dir + cd                  | `take`    | `take foo/bar`                     | `mkdir -p && cd`                        |
| Extraer archivos                | `extract` | `extract foo.tar.gz`               | Formatos comunes                        |
| Sesión tmux rápida              | `t`       | `t` · `t api`                      | `tmux new -A -s`                        |
| Papelera segura                 | `trash`   | `trash *.log`                      | Requiere `trash-cli`                    |
| Temporizador interactivo        | `tt`      | `tt`                               | Pulsa `Enter` para parar                |
| Top rápido filtrado             | `topme`   | `topme`                            | Muestra procesos típicos de stack web   |
| Cambiar `.env` seguro           | `envswap` | `envswap list` · `envswap use dev` | Copia `.env.<name>` → `.env` con backup |

**Dependencias (Arch):**

```bash
sudo pacman -S --needed fzf fd ripgrep bat eza zoxide wl-clipboard xclip trash-cli docker docker-compose bc
```

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

---

### NeoVim (`config/nvim/lua/keymaps.lua`)

- Window nav: **Ctrl+h/j/k/l** · Resize: **Ctrl+Arrows** · Save: **<leader>w**
- Search: **Ctrl+f** opens `/` · Move line: **Alt+j / Alt+k**

### tmux

- Focus: **Ctrl+h/j/k/l** · Splits: Prefix+`"`/`%` · Resize: Ctrl/Alt+Arrows
- Zoom: `z` · Layout cycle: `Space` · Find-window: `f` · Trees: `w/s/S`

### Kitty / i3 / Polybar / Dunst / Rofi

- Kitty: **Ctrl+Shift+C/V/N/Enter**, URLs with **Ctrl+click**
- i3: `$mod`=Super · scratch terminal `$mod+Shift+Return` · resize `$mod+Shift+Arrows`
- Polybar: mic left-click toggle, updates left-click terminal / right-click notify
- Dunst: `dunstctl set-paused toggle` · test with `notify-send "Test" "Dunst OK"`
- Rofi: `$mod+d` drun · `$mod+Shift+d` window · `$mod+F11` run · `$mod+v` clipmenu

---

## Quick CLI helpers (from `~/.bash_functions`)

**Navigation & Search:** `fo`, `cdf`, `rgf`, `grt`, `recent`, `fhist`  
**Git:** `gcof`, `gbr`, `gstaged`, `gundo`, `gclean`, `checkpoint`, `wip`, `fixup`, `watchdiff`  
**Docker:** `docps`, `dlogs`, `dsh`  
**System:** `fkill`, `cb`, `bench`, `ports`, `redo`, `todo`, `take`, `extract`, `t`, `trash`, `tt`, `topme`, `envswap`

**Install deps (Arch):**

```bash
sudo pacman -S --needed fzf fd ripgrep bat eza zoxide wl-clipboard xclip trash-cli docker docker-compose bc
```
