# Keymap maestro — i3 + tmux + Neovim + shell

Convenciones:

- `Super` = tecla Windows (i3 `$mod`).
- `Prefix` = `Ctrl-s` en tmux (tu prefijo).
- `Leader` (Neovim) = `<Space>` en modo normal.
- Las teclas se interpretan siempre “dentro” de la capa: i3 → terminal (kitty) → tmux → Neovim / shell.

---

## 1. i3 (gestor de ventanas)

### 1.1 Lanzadores y scratchpads

| Tecla                    | Acción                                                                 |
|--------------------------|------------------------------------------------------------------------|
| `Super+Enter`            | Abrir `kitty` dentro de tmux, adjuntando/creando `main`                |
| `Super+d`                | Rofi modo “Aplicaciones” (`drun` con iconos)                          |
| `Super+F11`              | Rofi `run` a pantalla completa                                        |
| `Super+f`                | Rofi `window` (alternativa rápida de cambio de ventana)               |
| `Super+v`                | `clipmenu` (historial de portapapeles con rofi)                       |
| `Super+Shift+Return`     | `toggle_scratch.sh` (terminal en scratchpad)                          |
| `Super+Shift+n`          | `toggle_scratch_obsidian.sh` (scratchpad de Obsidian)                 |

### 1.2 Ventanas, foco y layouts

> Nota: en tu config usas variables `$left/$right/$up/$down` para mapear a `h/j/k/l` + cursores.

| Tecla                                 | Acción                                      |
|---------------------------------------|---------------------------------------------|
| `Super+h/j/k/l`           | Mover foco entre ventanas                   |
| `Super+Shift+h/j/k/l`     | Mover la ventana actual                     |
| `Super+Shift+space`                   | Alternar flotante ↔ mosaico                 |
| `Super+z`                             | Pantalla completa (fullscreen toggle)       |
| `Super+e`                             | Alternar layout “split”                     |
| `Super+w`                             | Layout `tabbed`                             |
| `Super+s`                             | Layout `stacking`                           |
| `Super+Alt+h`                         | Split horizontal (`split h`)                |
| `Super+Alt+v`                         | Split vertical (`split v`)                  |
| `Super+r`                             | Entrar en modo resize                       |
| `h/j/k/l` en modo resize              | Redimensionar izquierda/abajo/arriba/derecha |
| `q` / `Escape` / `Return` en modo resize | Salir del modo resize                    |
| `Super+q`                             | Cerrar ventana con confirmación             |

### 1.3 Workspaces y monitores

| Tecla                          | Acción                                       |
|--------------------------------|----------------------------------------------|
| `Super+1`…`Super+0`           | Cambiar a workspace 1…10 (DEV/OPS/WEB/DOC/AI/DATA/TERM/CHAT/MEDIA/MISC) |
| `Super+Shift+1`…`Super+Shift+0` | Mover ventana actual a workspace 1…10      |
| `Super+Ctrl+Left/Right`        | Mover contenedor a salida (monitor) izq/der |

### 1.4 Audio, brillo, sistema, notificaciones

| Tecla                      | Acción                                        |
|----------------------------|-----------------------------------------------|
| `XF86MonBrightnessUp/Down` | Subir / bajar brillo (`brightnessctl`)        |
| `XF86AudioRaise/LowerVolume` | Volumen +/− (y refresco de Polybar)        |
| `XF86AudioMute`            | Mute de salida                                |
| `XF86AudioMicMute`         | Mute de micrófono                             |
| `XF86AudioPlay/Pause/Next/Prev` | Controles multimedia (`playerctl`)     |

Sistema y notificaciones:

| Tecla                    | Acción                                                 |
|--------------------------|--------------------------------------------------------|
| `Ctrl+Alt+Delete`        | Script `mode_system.sh` (power menu: apagar/reboot…)  |
| `Super+Shift+e`          | Diálogo de salida de i3 (`i3-nagbar`)                 |
| `Super+Shift+c`          | Reload de config de i3                                |
| `Super+Shift+r`          | Restart de i3                                         |
| `Super+y`                | Mostrar última notificación (`dunstctl history-pop`)  |
| `Super+Shift+y`          | Toggle de notificaciones (script polybar/dunst)       |

Screenshots:

| Tecla            | Acción                                    |
|------------------|-------------------------------------------|
| `Super+F2`       | Captura de selección (maim + slop)         |
| `Super+Shift+F2` | Captura de pantalla completa (maim)       |

---

## 2. tmux (multiplexor en kitty)

### 2.1 Navegación entre panes

`Prefix` = `Ctrl-s`.

La ruta principal de entrenamiento es `Prefix` + una tecla = una acción
completa. `h/j/k/l` mueve el foco; `H/J/K/L` redimensiona.

| Tecla             | Acción                                       |
|-------------------|----------------------------------------------|
| `Prefix+h/j/k/l`  | Mover foco al pane Izq/Abajo/Arriba/Dcha     |
| `Prefix+Tab`      | Siguiente pane (`select-pane -t :.+`)        |
| `Prefix+p`        | Mostrar overlay de panes (`display-panes`)   |

### 2.2 Gestión de panes (split / join / zoom / kill)

| Tecla               | Acción                                                                               |
|---------------------|--------------------------------------------------------------------------------------|
| `Prefix+d`          | Split abajo en el mismo cwd                                                         |
| `Prefix+r`          | Split derecha en el mismo cwd                                                       |
| `Prefix+!`          | Romper pane → nueva ventana (`break-pane`, nombre `cmd — directorio`)               |
| `Prefix+z`          | Zoom de pane (`resize-pane -Z` + mensaje de estado)                                 |
| `Prefix+q`          | Cerrar pane actual con confirmación (`kill-pane`)                                   |
| `Prefix+Backspace`  | Cerrar todos los panes salvo el actual, con confirmación (`kill-pane -a`)           |

### 2.3 Ventanas y sesiones

| Tecla             | Acción                                                          |
|-------------------|-----------------------------------------------------------------|
| `Prefix+c`        | Nueva ventana en cwd del pane actual                            |
| `Prefix+0..9`     | Cambiar a ventana 0..9                                          |
| `Prefix+s`        | `choose-tree -sw` (selector de sesiones/ventanas)               |
| `Prefix+S`        | SessionX (o selector de tmux como fallback)                    |
| `Prefix+n/N`      | Ventana siguiente/anterior                                      |
| `Prefix+a`        | Volver a la última ventana                                     |
| `Prefix+<`/`>`    | Mover ventana izquierda/derecha                                |
| `Prefix+E`/`V`    | Layout even-horizontal/even-vertical                           |
| `Prefix+,`        | Renombrar ventana                                               |
| `Prefix+$`        | Renombrar sesión                                                |
| `Prefix+A`        | Adjuntar/cambiar a una sesión de proyecto                       |

Reload / ayuda:

| Tecla        | Acción                                             |
|--------------|----------------------------------------------------|
| `Prefix+R`   | `source-file ~/.tmux.conf` + mensaje “Config reloaded!” |
| `Prefix+?`   | Abrir esta cheatsheet en un popup                    |

### 2.4 Copy-mode y buffers

| Tecla       | Acción                                      |
|-------------|---------------------------------------------|
| `Prefix+[`  | Entrar en copy-mode (vi)                    |
| `Prefix+]`  | Pegar desde el buffer (`paste-buffer`)      |
| `Prefix+#`  | Listar buffers                              |
| `Prefix+-`  | Eliminar buffer actual (`delete-buffer`)    |

En copy-mode-vi sigues la semántica estándar de tmux/vi (navegar con `hjkl`, buscar con `/` y `?`, seleccionar con `v`, copiar con `Enter`, etc. salvo cambios que tú añadas).

Los atajos sin prefijo `C-h/j/k/l`, `F10`, `M-S-flechas`, `M-flechas` y
`C-PageUp/Down` se mantienen como integración o compatibilidad, pero no son la
ruta principal. `Prefix+"`, `Prefix+%`, `Prefix+Space` y `Prefix+Z` fueron
retirados para evitar conflictos; `Prefix+H` tampoco forma parte del mapa
principal porque `Prefix+b` abre `btop`.

### 2.5 Popups y utilidades integradas

| Tecla        | Acción                                                                        |
|--------------|-------------------------------------------------------------------------------|
| `Prefix+g`   | Abrir `lazygit` en popup (90% pantalla, centrado)                            |
| `Prefix+b`   | Abrir `btop` en popup                                                        |
| `Prefix+x`   | Abrir extrakto                                                               |
| `Prefix+m`   | Abrir tmux-menus                                                             |
| `Prefix+C-p/C-w/C-b` | fzf para panes / ventanas / buffers                                  |
| `Prefix+u/U` | Resurrect: guardar / restaurar sesión                                        |
| `Prefix+Y`   | Copiar `#{pane_current_path}` a tu clipboard (`copy_cmd`), mensaje “Ruta copiada” |
| `Prefix+f`   | Buscar ventana por nombre (`find-window`)                                    |

---

## 3. Neovim

### 3.1 Navegación de ventanas / integración con tmux (Ctrl-*)

| Tecla         | Acción                                         |
|---------------|------------------------------------------------|
| `<C-h/j/k/l>` | `TmuxNavigate*` (mover foco entre panes nvim/tmux) |
| `<C-B>`       | Abrir/cerrar Explorer (toggle)                 |
| `<C-P>`       | Buscar archivo (Find Files)                    |
| `<C-F>`       | Abrir prompt de búsqueda (`/`)                 |
| `<C-Up/Down>` | Aumentar / disminuir altura del split         |
| `<C-Left/Right>` | Aumentar / disminuir anchura del split     |
| `<C-_>`       | Toggle comment (también en visual)             |

Buffers y pantalla:

| Tecla | Acción              |
|-------|---------------------|
| `H`   | Buffer anterior     |
| `L`   | Buffer siguiente    |
| `gH`  | Ir al principio de pantalla |
| `gL`  | Ir al final de pantalla    |

### 3.2 Leader `<Space>` — ventanas y navegación

| Tecla              | Acción                                  |
|--------------------|-----------------------------------------|
| `<Space>"`         | Split horizontal                        |
| `<Space>%`         | Split vertical                          |
| `<Space><BS>`      | Cerrar todas las ventanas salvo la actual |
| `<Space><Space>`   | Limpiar highlight de búsqueda           |
| `<Space>e`         | Foco en Explorer                        |
| `<Space>ff`        | Buscar archivo (Telescope / similar)    |
| `<Space>fg`        | Buscar texto en el workspace            |
| `<Space>fr`        | Archivos recientes                      |
| `<Space>fb`        | Lista de buffers                        |
| `<Space>s`         | Cambiar de buffer (switch buffer)       |
| `<Space>q`         | Cerrar ventana                          |
| `<Space>w`         | Guardar buffer actual (`:write`)        |
| `<Space>P`         | Command Palette                         |
| `<Space>`\`        | Terminal (fallback)                     |

### 3.3 LSP, símbolos y diagnósticos

| Tecla        | Acción                           |
|--------------|----------------------------------|
| `<Space>cs`  | Symbols Outline (árbol de símbolos) |
| `<Space>xd`  | Diagnósticos del buffer         |
| `<Space>xx`  | Diagnósticos del workspace      |
| `<Space>xl`  | Abrir `loclist`                 |
| `<Space>xq`  | Abrir `quickfix`                |
| `<Space>cf`  | Formatear buffer (normal y visual) |

### 3.4 Debug (DAP)

Teclas de función:

| Tecla  | Acción                         |
|--------|--------------------------------|
| `<F5>` | Debug: Start / Continue        |
| `<F9>` | Debug: Toggle Breakpoint       |

Cluster `<Space>d*`:

| Tecla        | Acción                     |
|--------------|----------------------------|
| `<Space>db`  | Toggle Breakpoint          |
| `<Space>dB`  | Breakpoint condicional     |
| `<Space>d0`  | Step Over                  |
| `<Space>dI`  | Step Into                  |
| `<Space>dU`  | Step Out                   |
| `<Space>dc`  | Continue                   |
| `<Space>de`  | Debug: Eval                |
| `<Space>dl`  | Ejecutar última sesión (Run Last) |
| `<Space>dr`  | Toggle REPL                |
| `<Space>du`  | Toggle UI de debug         |

### 3.5 Tasks, toggles y miscelánea

| Tecla         | Acción                                   |
|---------------|------------------------------------------|
| `<Space>or`   | Run Task                                 |
| `<Space>ot`   | Toggle Tasks                             |
| `<Space>tn`   | Toggle `relativenumber`                  |
| `<Space>ts`   | Toggle spell (es/en)                     |
| `<Space>tw`   | Toggle wrap                              |
| `<Space>un`   | Dismiss notifications                    |

---

## 4. Shell (bash/readline + Atuin/ble)

### 4.1 Atajos estándar de edición (readline)

De tu `bind -P` actual:

| Tecla | Acción                                  |
|-------|-----------------------------------------|
| `Ctrl-l` | Limpiar pantalla (`clear-screen`)   |
| `Ctrl-u` | Borrar desde cursor hasta inicio de línea |
| `Ctrl-w` | Borrar palabra anterior              |
| `Ctrl-y` | Pegar último texto borrado (`yank`) |

Por defecto en bash/readline (aunque no salen todos en tu dump, los estás usando seguro):

| Tecla   | Acción                                   |
|---------|------------------------------------------|
| `Ctrl-a` | Ir al principio de la línea             |
| `Ctrl-e` | Ir al final de la línea                 |
| `Alt-f` / `Alt-b` | Avanzar / retroceder una palabra |
| `Ctrl-k` | Borrar desde cursor hasta final de línea |

### 4.2 Historial

En tu `bind -P`:

| Tecla   | Acción                               |
|---------|--------------------------------------|
| `Ctrl-r` | `reverse-search-history` (búsqueda incremental hacia atrás) |

En la práctica, en tu entorno real lo tienes redirigido vía `ble.sh` a FZF/Atuin (historial interactivo numerado). El comportamiento exacto depende de si está activo Atuin o el widget `fzf-history-widget`, pero la tecla “canónica” sigue siendo `Ctrl-r` para “buscar en historial”.

---

## 5. Cómo usar este keymap maestro

1. **Imprimirlo** o tenerlo en tu repo de dotfiles (`docs/keymap-maestro.md`) y abrirlo con un `Prefix+?` en tmux o como nota “pinned” en Obsidian.
2. **Revisar colisiones**: si alguna tecla no te gusta o no la recuerdas nunca, es candidata a reciclar. Empieza por tmux (`Prefix+?`) y por `<Space>` en Neovim.
3. **Definir reglas globales** (ejemplo):  
   - `s` = “switch/selector” (`Super+s` layout stack; `Prefix+s` tree de sesiones; `<Space>s` switch de buffer).  
   - `g` = “git/graph” (`Prefix+g` lazygit; `<Space>gg` lazygit en Neovim).  
   Mantener estas familias te baja mucho la carga cognitiva.
