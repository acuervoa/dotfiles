# TMUX CHEATSHEET — completo y práctico

> Convención de este proyecto: **prefijo = C-s**.  
> Comandos tmux se lanzan con `C-s :` o desde shell como `tmux <cmd>`.

## 0) Servidor, clientes y versión
- Versión: `tmux -V`
- Iniciar servidor (implícito al usar tmux): `tmux start-server`
- Info servidor: `tmux server-info`
- Matar servidor (cierra todo): `tmux kill-server`
- Clientes: `tmux list-clients`, `tmux detach-client -t <client>`, `tmux switch-client -t <sesión>`, `tmux refresh-client`

## 1) Sesiones
- Crear/adjuntar:
  - **Nuevo** (en BG si ya estás en tmux): `tmux new-session -d -s work [-n win] [-c dir] ['cmd']`
  - Adjuntar: `tmux attach-session -t work`  |  crear o adjuntar: `tmux new -Ad -s work`
- Cambiar de sesión desde dentro: `C-s : switch-client -t work`  |  última: `switch-client -l`
- Listar: `tmux list-sessions`
- Renombrar: `tmux rename-session -t work newname`
- Comprobar si existe: `tmux has-session -t work`
- Cerrar: `tmux kill-session -t work`

## 2) Ventanas
- Crear: `tmux new-window [-d] [-n nombre] [-c dir] ['cmd']`
- Seleccionar: `tmux select-window -t :1`  |  siguiente/anterior: `next-window` / `previous-window`  |  última: `last-window`
- Listar: `tmux list-windows [-a] -F '#{session_name}:#I:#W #{window_layout}'`
- Renombrar: `tmux rename-window -t :1 logs`
- Mover: `tmux move-window -s dojo:misc -t alt:` (a otra sesión) | `move-window -t :1` (reordenar)
- Intercambiar: `tmux swap-window -s :1 -t :3`
- Enlazar/desenlazar: `tmux link-window -s dojo:2 -t alt:` | `tmux unlink-window -t :2`
- Respawn (relanzar): `tmux respawn-window [-k] -t :2 ['cmd']`
- Cerrar: `tmux kill-window -t :2`
- Buscar: `tmux find-window texto`

## 3) Paneles (splits)
- Split: `tmux split-window -v` (divide horizontalmente en filas) | `-h` (vertical: columnas)
  - Tamaño: `-l <cells>` o `-p <porcentaje>`  |  dir: `-c <dir>`  |  comando inicial: `'cmd'`
- Selección: `tmux select-pane -L/-R/-U/-D`  |  por índice: `-t :.+`  |  mostrar índices: `display-panes`
- Redimensionar: `tmux resize-pane -L/-R/-U/-D [N]`  |  **zoom**: `tmux resize-pane -Z` (o `C-s z`)
- Intercambiar: `tmux swap-pane -s :2.1 -t :2.3`  |  atajos: `swap-pane -D/-U`
- Unir/romper:
  - **join** (trae pane a esta ventana): `tmux join-pane -s dojo:solo -t :2 [-h|-v]`
  - **break** (pane → ventana nueva): `tmux break-pane -d -n solo`
- Listar: `tmux list-panes [-a] -F '#{session_name}:#W:#P active=#{?pane_active,1,0} size=#{pane_width}x#{pane_height}'`
- Cerrar: `tmux kill-pane -t :2.3`

## 4) Layouts y rotaciones
- Predefinidos: `tmux select-layout even-horizontal | even-vertical | main-horizontal | main-vertical | tiled`
- Ciclar: `tmux next-layout` / `tmux previous-layout`
- Rotar: `tmux rotate-window -U` (o `-D`)
- Consultar: `tmux display -p '#{window_layout}'`

## 5) Copy-mode, búsqueda y portapapeles
- Entrar: `tmux copy-mode` (en vi-keys: movimientos `h/j/k/l`, `PageUp/Down`)
- Buscar: `/texto` (siguiente `n`, anterior `N`)
- Selección:
  - **vi** (`set -g mode-keys vi`): `v`… mover… `y` (yank)
  - **emacs**: `Space`… mover… `Enter` (copia)
- Pegar: `tmux paste-buffer` (o `C-s ]` si lo tienes mapeado)
- Buffers: `tmux list-buffers`, `tmux show-buffer`, `tmux delete-buffer -b 0`, `tmux save-buffer /tmp/buf.txt`, `tmux load-buffer /tmp/file`
- Captura de pane: `tmux capture-pane -pS -1000 > /tmp/cap.txt`
- **OSC52 / clipboard**: `set -g set-clipboard on` (si tu terminal soporta OSC52)

## 6) Árbol, selección y prompt
- Árbol unificado (sesiones/ventanas): `tmux choose-tree [-Zw]`  (muy útil: `-Z` respeta zoom)
- Árbol directo de ventanas: `tmux choose-window`  |  de sesiones: `tmux choose-session`
- Prompt de comandos: `tmux command-prompt [-p "Mensaje"] "plantilla"`
  - Ej.: `command-prompt -p "New session:" "new-session -d -s '%%'; switch-client -t '%%'"`

## 7) Opciones y “set” (globales, de sesión y de ventana)
- Ver opciones: `tmux show -g` (globales) | `show -s` (servidor) | `show -w` (ventana)
- Ajustes típicos:
  - **Prefijo**: `set -g prefix C-s` ; `unbind C-b` ; `bind C-s send-prefix`
  - **Ratón**: `set -g mouse on`
  - **Sincronizar panes**: `set-window-option -g synchronize-panes on`
  - **Copy-mode vi**: `set -g mode-keys vi`
  - **Status bar**:  
    - Toggle: `set -g status on|off`, intervalo: `set -g status-interval 5`
    - Estilos: `set -g status-style bg=default,fg=colour250`
    - Ventanas: `set -g window-status-format '#I:#W'`
    - Ventana activa: `set -g window-status-current-format '#[bold]#I:#W'`
- Recargar config: `tmux source-file ~/.tmux.conf`

## 8) Formatos (placeholders) más útiles
- `#S` sesión · `#I` índice de ventana · `#W` nombre ventana · `#P` índice pane  
- `#{pane_current_path}` · `#{pane_pid}` · `#{window_layout}` · `#{session_windows}`  
- Condicional: `#{?condition,if,else}`
- Ver un formato: `tmux display-message -p '#S:#I:#W pane=#{pane_index}'`

## 9) Hooks (automatización)
- Ver hooks: `tmux show-hooks -g`
- Definir: `tmux set-hook -g after-new-window 'display-message "Nueva ventana: #W"'`
- Hooks útiles: `after-new-session`, `after-new-window`, `pane-died`, `window-linked`, `client-session-changed`

## 10) Binds, unbinds y scripting
- Bind: `tmux bind-key -n C-h select-pane -L` (sin prefijo) | con prefijo: `tmux bind j select-pane -D`
- Unbind: `tmux unbind-key C-h`
- Cargar fichero: `tmux source-file ~/.tmux.conf`
- Condicional: `tmux if-shell 'test -x ~/.local/bin/foo' 'run-shell ~/.local/bin/foo'`
- Run shell: `tmux run-shell "echo hola > /tmp/x"`

## 11) Buscar y filtrar
- Buscar ventana por título/contenido: `tmux find-window texto`
- Greps típicos:
  - Binds relevantes: `tmux list-keys | grep -E 'select-pane|resize-pane|copy-mode|choose-tree'`
  - Opciones clave: `tmux show -g | grep -E 'prefix|mouse|mode-keys|status|set-clipboard'`

## 12) Resumen de mandos clave (según nuestras convenciones)
- **Sesiones**: `new -Ad -s N`, `switch-client -t N`, `kill-session -t N`
- **Ventanas**: `new-window [-n]`, `select-window -t :N`, `move-window -t :N`, `swap-window`, `kill-window`
- **Paneles**: `split-window -h|-v`, `select-pane -L/R/U/D`, `resize-pane -L/R/U/D [N]`, `swap-pane`, `join-pane`, `break-pane`, `resize-pane -Z`
- **Layouts**: `select-layout <tipo>`, `next-layout`, `rotate-window -U`
- **Copy/pegar**: `copy-mode`, `/texto`, `y` (vi) o `Enter` (emacs), `paste-buffer`
- **Buffers/logs**: `capture-pane -pS -1000 > file`, `list-buffers`, `save-buffer`
- **Árbol**: `choose-tree -Zw`  |  **Prompt**: `command-prompt`

> Nota: todos los comandos son **nativos** de tmux. Revisa `man tmux` para detalles finos (flags o cambios entre versiones).
