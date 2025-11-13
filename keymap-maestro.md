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
| `Super+Enter`            | Abrir `kitty`                                                          |
| `Super+d`                | Rofi modo “Aplicaciones” (`drun` con iconos)                          |
| `Super+Shift+d`          | Rofi modo “Ventanas abiertas”                                         |
| `Super+F11`              | Rofi `run` a pantalla completa                                        |
| `Super+f`                | Rofi `window` (alternativa rápida de cambio de ventana)               |
| `Super+v`                | `clipmenu` (historial de portapapeles con rofi)                       |
| `Super+Shift+Return`     | `toggle_scratch.sh` (terminal en scratchpad)                          |
| `Super+Shift+n`          | `toggle_scratch_obsidian.sh` (scratchpad de Obsidian)                 |

### 1.2 Ventanas, foco y layouts

> Nota: en tu config usas variables `$left/$right/$up/$down` para mapear a `h/j/k/l` + cursores.

| Tecla                                 | Acción                                      |
|---------------------------------------|---------------------------------------------|
| `Super+h/j/k/l` o `Super+←/↓/↑/→`     | Mover foco entre ventanas                   |
| `Super+Shift+h/j/k/l` o `Super+Shift+←/↓/↑/→` | Mover la ventana actual                     |
| `Super+Shift+space`                   | Alternar flotante ↔ mosaico                 |
| `Super+z`                             | Pantalla completa (fullscreen toggle)       |
| `Super+e`                             | Alternar layout “split”                     |
| `Super+w`                             | Layout `tabbed`                             |
| `Super+s`                             | Layout `stacking`                           |
| `Super+Alt+h`                         | Split horizontal (`split h`)                |
| `Super+Alt+v`                         | Split vertical (`split v`)                  |
| `Super+Shift+←/→/↑/↓`                | Redimensionar ventana (±10 px/ppt)         |
| `Super+q`                             | Cerrar ventana (`kill`)                     |

### 1.3 Workspaces y monitores

| Tecla                          | Acción                                       |
|--------------------------------|----------------------------------------------|
| `Super+1`…`Super+0`           | Cambiar a workspace 1…10                     |
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
| `Super+F2`       | Captura de pantalla completa (flameshot)  |
| `Super+Shift+F2` | Flameshot GUI (selección interactiva)     |

---

## 2. tmux (multiplexor en kitty)

### 2.1 Navegación entre panes

`Prefix` = `Ctrl-s`.

| Tecla             | Acción                                       |
|-------------------|----------------------------------------------|
| `Prefix+h/j/k/l`  | Mover foco al pane Izq/Abajo/Arriba/Dcha     |
| `Prefix+Tab`      | Siguiente pane (`select-pane -t :.+`)        |
| `Prefix+Space`    | Mostrar overlay de panes (`display-panes`)   |

### 2.2 Gestión de panes (split / join / zoom / kill)

| Tecla               | Acción                                                                               |
|---------------------|--------------------------------------------------------------------------------------|
| `Prefix+"`          | Split horizontal (pane abajo) en el mismo cwd                                       |
| `Prefix+%`          | Split vertical (pane derecha) en el mismo cwd                                       |
| `Prefix+!`          | Romper pane → nueva ventana (`break-pane`, nombre `cmd — directorio`)               |
| `Prefix+Z` / `Prefix+z` | Zoom de pane (`resize-pane -Z` + mensaje de estado)                         |
| `Prefix+q`          | Cerrar pane actual (`kill-pane`)                                                    |
| `Prefix+Backspace`  | Cerrar todos los panes salvo el actual (`kill-pane -a`)                             |

### 2.3 Ventanas y sesiones

| Tecla             | Acción                                                          |
|-------------------|-----------------------------------------------------------------|
| `Prefix+c`        | Nueva ventana en cwd del pane actual                            |
| `Prefix+0..9`     | Cambiar a ventana 0..9                                          |
| `Prefix+w`        | `choose-tree -Zw` (selector de ventanas/panes)                  |
| `Prefix+s`        | `choose-tree -sw` (selector de sesiones/ventanas)               |
| `Prefix+&`        | Cerrar ventana actual (con confirmación)                        |
| `Prefix+,`        | Renombrar ventana                                               |
| `Prefix+$`        | Renombrar sesión                                                |
| `Prefix+d`        | `detach-client` (soltar la sesión)                              |
| `Prefix+D`        | `choose-client -Z` (selector de clientes)                       |
| `Prefix+(`/`)`    | Cambiar cliente anterior / siguiente                            |

Reload / ayuda:

| Tecla        | Acción                                             |
|--------------|----------------------------------------------------|
| `Prefix+r`   | `source-file ~/.tmux.conf` + mensaje “Config reloaded!” |
| `Prefix+R`   | Reload robusto (script más elaborado)              |
| `Prefix+?`   | Listar todos los keybindings de tmux (`list-keys`) |

### 2.4 Copy-mode y buffers

| Tecla       | Acción                                      |
|-------------|---------------------------------------------|
| `Prefix+[`  | Entrar en copy-mode (vi)                    |
| `Prefix+]`  | Pegar desde el buffer (`paste-buffer`)      |
| `Prefix+#`  | Listar buffers                              |
| `Prefix+-`  | Eliminar buffer actual (`delete-buffer`)    |

En copy-mode-vi sigues la semántica estándar de tmux/vi (navegar con `hjkl`, buscar con `/` y `?`, seleccionar con `v`, copiar con `Enter`, etc. salvo cambios que tú añadas).

### 2.5 Popups y utilidades integradas

| Tecla        | Acción                                                                        |
|--------------|-------------------------------------------------------------------------------|
| `Prefix+g`   | Abrir `lazygit` en popup (90% pantalla, centrado)                            |
| `Prefix+H`   | Abrir `btop` en popup                                                        |
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


