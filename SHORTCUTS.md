# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Convenciones

- **tmux Prefix:** `Ctrl+s` (añade `stty -ixon` en `~/.bashrc` para liberarlo).
- **NeoVim Leader:** `Espacio` (`<leader>`). `maplocalleader = ,`.
- **Vim Leader:** `Espacio` (`<leader>`). `maplocalleader = ,`.
- **i3 $mod:** `Super` (tecla Windows).
- Las tablas siguientes son bilingües: cada fila muestra «Atajo / Shortcut» y «Descripción / Action».

### Atajos por entorno / Shortcuts by environment

#### tmux (`tmux/tmux.conf`)

**Globales (sin prefijo)**

| Atajo / Shortcut | Contexto | Descripción / Action | Notas |
| ---------------- | -------- | -------------------- | ----- |
| `Ctrl+s` | Normal | Envía el prefijo manualmente (`send-prefix`). | Requiere `stty -ixon` para liberar `Ctrl+s`. |
| `Alt+h` `Alt+j` `Alt+k` `Alt+l` | Normal | Cambia al panel izquierdo/abajo/arriba/derecha. | `bind -n M-{h,j,k,l}`. |
| `Alt+Shift+←/→/↑/↓` | Normal | Redimensiona pane: izquierda/derecha ±5, arriba/abajo ±2. | `bind -n M-S-{Left,Right,Up,Down}`. |
| `Ctrl+PageDown` / `Ctrl+PageUp` | Normal | Cambia de ventana siguiente / anterior. | `bind -n C-Page{Down,Up}`. |
| `Alt+←/→` | Normal | Cambia a ventana previa / siguiente. | `bind -n M-{Left,Right}`. |
| `F10` | Normal | Activa/desactiva sincronización de paneles y muestra estado. | `bind -n F10`. |
| `Ctrl+h/j/k/l` | Normal | Si pane activo es Vim/Neovim envía movimiento, en caso contrario intenta moverse entre paneles. | **Bug:** fallback usa `select-pana` (typo) y falla, ver [Conflictos](#observaciones). |
| `Mouse` | Copy-mode | Ratón habilitado (`set -g mouse on`). | Permite selección/scroll. |

**Con prefijo (`Ctrl+s`)**

| Atajo / Shortcut | Descripción / Action | Notas |
| ---------------- | -------------------- | ----- |
| `"` | Divide panel horizontal (split-window -v) en mismo cwd. |
| `%` | Divide panel vertical (split-window -h) en mismo cwd. |
| `BSpace` | Cierra todos los paneles excepto el actual (`kill-pane -a`). |
| `q` | Cierra panel actual (`kill-pane`). |
| `a` | Cambia a la última ventana usada (`last-window`). |
| `Tab` / `Shift+Tab` | Cicla paneles siguiente / anterior (`select-pane -t :.+ / :.-`). |
| `{` / `}` | Intercambia panel actual con anterior / siguiente. |
| `Z` | Alterna zoom en panel y muestra estado. |
| `h` `j` `k` `l` | Navega paneles (repetible). |
| `r` | Recarga configuración (`source-file ~/.tmux.conf`). |
| `F` | Lanza `tmux-fzf`. |
| `m` | Abre `tmux-menus`. |
| `s` | Selector de sesiones/ventanas (`choose-tree -sw`). |
| `Shift+S` | Abre `tmux-sessionx` si existe; si no, `choose-tree`. |
| `f` | Busca ventana (`find-window`). |

**Copy-mode (vi)**

| Atajo / Shortcut | Descripción / Action |
| ---------------- | -------------------- |
| `Enter` | Copia selección y sale (`copy-pipe-and-cancel` a clipboard auto). |
| `y` | Copia selección y sale. |
| `v` | Inicia selección visual. |
| `V` | Selecciona línea. |
| `Ctrl+v` | Selección rectangular. |
| `Esc` | Cancela selección. |

**Plugins / extras**

| Atajo / Shortcut | Descripción / Action |
| ---------------- | -------------------- |
| `Prefix+x` | Lanza `extrakto` (configurado vía `@extrakto_key`). |
| `Prefix+F` | Ejecuta `tmux-fzf`. |
| `Prefix+m` | Ejecuta `tmux-menus`. |

#### i3 (`config/i3/config`)

**Lanzadores y scratchpads**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `$mod+Return` | Abre terminal kitty. |
| `$mod+Shift+Return` | Alterna scratchpad de kitty (`toggle_scratch.sh`). |
| `$mod+Shift+n` | Alterna scratchpad de Obsidian (`toggle_scratch_obsidian.sh`). |
| `$mod+d` | Rofi modo `drun`. |
| `$mod+Shift+d` | Rofi selector de ventanas. |
| `$mod+F11` | Rofi modo `run` fullscreen. |
| `$mod+v` | `clipmenu` con Rofi. |

**Brillo, audio y multimedia**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `XF86MonBrightnessUp/Down` | Ajusta brillo ±5% (brightnessctl). |
| `XF86AudioRaise/LowerVolume` | Sube / baja volumen (script `volctl`). |
| `XF86AudioMute` | Mute/unmute audio (volctl). |
| `XF86AudioMicMute` | Alterna micro (micctl). |
| `Shift+XF86AudioRaise/LowerVolume` | Ajusta ganancia de micro ± (micctl). |
| `XF86AudioPlay/Pause/Next/Prev` | Control multimedia vía playerctl. |

**Gestión de foco y ventanas**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `$mod+$left/$down/$up/$right` | Foco direccional (usando variables h/j/k/l). |
| `$mod+Left/Down/Up/Right` | Foco direccional (teclas de cursor físicas). |
| `$mod+Tab` | Workspace anterior (back_and_forth). |
| `$mod+Shift+$left/$down/$up/$right` | Mueve la ventana en esa dirección. |
| `$mod+Shift+space` | Alterna flotante/tiling. |
| `$mod+space` | Alterna foco entre modos. |
| `$mod+z` | Pantalla completa. |
| `$mod+f` | Rofi window (finder). |
| `$mod+s` / `$mod+w` / `$mod+e` | Layout stacking / tabbed / toggle split. |
| `$mod+Alt+h` / `$mod+Alt+v` | Forzar split horizontal / vertical. |
| `$mod+Shift+←/→/↑/↓` | Redimensiona contenedor 10 px/ppt. |
| `$mod+Ctrl+Left/Right` | Mueve contenedor a monitor izquierdo/derecho. |

**Workspaces**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `$mod+1..0` | Cambia a workspace `1`..`10`. |
| `$mod+Shift+1..0` | Mueve contenedor al workspace correspondiente. |

**Sistema y utilidades**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `$mod+Shift+c` | Recarga configuración. |
| `$mod+Shift+r` | Reinicia i3. |
| `$mod+Shift+e` | Pregunta para salir de i3. |
| `Ctrl+Alt+Delete` | Lanza menú de sistema (`mode_system.sh`). |
| `$mod+q` | Cierra ventana (`kill`). |
| `$mod+F2` / `$mod+Shift+F2` | Flameshot captura completa / GUI. |
| `$mod+Shift+y` | Alterna Do Not Disturb (dunst). |
| `$mod+y` | Reproduce última notificación (dunstctl history-pop). |

#### Kitty (`config/kitty/kitty.conf`)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `Ctrl+Shift+C` | Copia al portapapeles. |
| `Ctrl+Shift+V` | Pega desde portapapeles. |
| `Ctrl+Shift+N` | Nueva ventana del SO. |
| `Ctrl+Shift+Enter` | Nueva pestaña kitty. |
| `Ctrl+Click` | Abre URL bajo el cursor (`mouse_map ctrl+left`). |
| Selección directa | Copia automáticamente (`copy_on_select yes`). |

#### NeoVim (`config/nvim/...`)

**Ventanas, buffers y edición general** (`lua/config/keymaps.lua`)

| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |
| `Ctrl+h/j/k/l` | Normal | Navega a panel tmux/ventana nvim (TmuxNavigate*). |
| `Alt+h/l` | Normal | Mueve foco de ventana dentro de Neovim (`<C-w>h/l`). |
| `Alt+j/k` | Normal, Insert, Visual | Mueve línea/bloque arriba/abajo. |
| `Shift+Alt+j/k` | Normal, Visual | Duplica línea/selección abajo/arriba. |
| `<leader>q` | Normal | Cierra ventana actual. |
| `<leader>"` | Normal | Split horizontal. |
| `<leader>%` | Normal | Split vertical. |
| `<leader><BS>` | Normal | `:only` (cierra otras ventanas). |
| `<leader>s` | Normal | Lista buffers (`:ls`) y prepara `:b`. |
| `Alt+Shift+←/→` | Normal | Redimensiona vertical ±2 columnas. |
| `Alt+Shift+↑/↓` | Normal | Redimensiona horizontal ±1 fila. |
| `Ctrl+←/→/↑/↓` | Normal | Redimensiona ±2 (vertical) / ±1 (horizontal). |
| `<leader>w` | Normal | Guarda archivo actual. |
| `Ctrl+f` | Normal, Insert, Visual | Abre prompt `/` (búsqueda coherente). |

**Integración tmux-navigator** (`plugins/tmux-navigator.lua`)

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `Ctrl+h/j/k/l` | Repetido para garantizar navegación tmux. |
| `Ctrl+\` | Regresa al último pane (TmuxNavigatePrevious). |

**Explorador (Neo-tree)**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `Ctrl+b` | Alterna panel de ficheros a la izquierda. |
| `<leader>e` | Da foco al panel de ficheros. |
| Dentro de Neo-tree: `o`, `Enter`, `v`, `s`, `t` | Abrir archivo, vsplit, split, pestaña. |
| Dentro de Neo-tree: `Espacio` | Sin acción (deshabilitado). |

**Búsqueda y Telescope**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `Ctrl+p` | `Telescope find_files`. |
| `<leader>P` | `Telescope commands` (command palette). |
| `<leader>ff` / `fg` / `fb` / `fr` / `fs` | Ficheros, live_grep, buffers, recientes, símbolos del documento. |
| (Modo insert en Telescope) `Ctrl+n` / `Ctrl+p` | Siguiente / anterior resultado. |
| (Modo insert en Telescope) `Ctrl+u` / `Ctrl+d` | Deshabilitados (scroll nativo). |
| (Modo insert en Telescope) `Esc` | Cierra Telescope. |

**Git (Gitsigns + LazyGit)**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `]c` / `[c` | Sig./ant. hunk (respeta modo diff). |
| `<leader>hs` | Stage hunk (normal/visual). |
| `<leader>hr` | Reset hunk (normal/visual). |
| `<leader>hS` | Stage buffer completo. |
| `<leader>hu` | Undo stage hunk. |
| `<leader>hR` | Reset buffer. |
| `<leader>hp` | Previsualiza hunk. |
| `<leader>hb` | Blame línea (completo). |
| `<leader>hd` / `<leader>hD` | Diff buffer / diff contra `~`. |
| `ih` (objeto de texto) | Selecciona hunk en modos operador/visual. |
| `<leader>gg` | Abre LazyGit. |

**LSP y outline**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `gd` / `gD` / `gi` / `gt` | Go to definition / declaration / implementation / type. |
| `<F12>` | Go to definition alternativo. |
| `K` | Hover. |
| `<F2>` | Rename symbol. |
| `<leader>ca` | Code actions (normal y visual). |
| `<leader>cd` | Diagnóstico flotante. |
| `[d` / `]d` | Diagnóstico anterior / siguiente. |
| `<leader>ch` | Alterna inlay hints (si servidor lo soporta). |
| `<leader>cs` | Abre Outline (símbolos). |

**Formateo y lint**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `<leader>cf` | Formatea buffer/selección con Conform (n/v). |
| `:FormatToggle` (comando) | Alterna autoformat on save (creado por Conform). |

**DAP (depuración)**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `<F5>` | Iniciar/continuar. |
| `<F10>` | Step over. |
| `<F11>` / `<Shift+F11>` | Step into / step out. |
| `<F9>` | Alterna breakpoint. |
| `<leader>db` / `<leader>dB` | Toggle breakpoint / breakpoint condicional. |
| `<leader>dc` | Continue. |
| `<leader>dr` | Toggle REPL. |
| `<leader>dl` | Run last. |
| `<leader>du` | Toggle UI (`dapui`). |
| `<leader>de` | Eval (normal/visual). |

**Tareas, terminal, UI**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `<leader>ot` / `<leader>or` | Overseer Toggle / Run task. |
| `Ctrl+`` | Abre/cierra terminal flotante (ToggleTerm). |
| `<leader>`` | ToggleTerm (normal/terminal). |
| `<leader>un` | Limpia notificaciones (`nvim-notify`). |

**Comentarios y edición extra**

| Atajo / Shortcut | Acción |
| ---------------- | ------ |
| `Ctrl+/` (`Ctrl+_`) | Alterna comentario (Comment.nvim) en normal/visual. |
| `<C-Space>` | Expande selección incremental (Treesitter). |
| `<BS>` (incremental selection) | Reduce selección (Treesitter). |

**Completado (nvim-cmp + LuaSnip)**

| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |
| `Ctrl+n` / `Ctrl+p` | Insert | Siguiente / anterior sugerencia. |
| `Ctrl+b` / `Ctrl+f` | Insert | Scroll doc -4 / +4. |
| `Ctrl+Space` | Insert | Forzar completado. |
| `Ctrl+e` | Insert | Cancelar menú. |
| `Enter` | Insert | Confirma (selecciona por defecto). |
| `Tab` | Insert/Select | Siguiente sugerencia o expand/jump snippet. |
| `Shift+Tab` | Insert/Select | Sugerencia previa o retroceder snippet. |

#### Vim (clásico) (`vim/vimrc` + `vim/config/keymaps.vim`)

| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |
| `Ctrl+h/j/k/l` | Normal | Navegar ventanas (vim-tmux-navigator). |
| `Ctrl+b` / `<leader>e` | Normal | Abrir/centrar Fern file explorer. |
| `Ctrl+p` / `<leader>ff` | Normal | Buscar archivos (fzf). |
| `<leader>fr` / `<leader>fb` | Normal | Historial / buffers (fzf). |
| `<leader>sg` / `<leader>sw` | Normal | `Rg` global o palabra bajo cursor. |
| `<leader>ss` / `<leader>sS` | Normal | Símbolos documento/workspace (CoC). |
| `<leader>q` / `<leader>x` | Normal | Abrir buffers de notas (`~/buffer(.md)`). |
| `<leader>pp` | Normal | Alterna `paste`. |
| `<leader>w` | Normal | Guarda archivo (y `Ctrl+s` fuera de tmux). |
| `<leader><BS>` | Normal | `:only`. |
| `<leader>bd` / `<leader>bo` | Normal | Cerrar buffer actual / todos salvo actual. |
| `<leader>bd` (keymaps.vim) | Normal | `:Bclose` + `:tabclose`. |
| `<leader>ba` | Normal | Cierra todos los buffers. |
| `<leader>tn/to/tc/tm/t<leader>/tl/te` | Normal | Gestión de pestañas (nueva, only, close, move, next, reopen última, abrir en dir de archivo). |
| `<leader>cd` | Normal | `:cd` al dir del archivo y `:pwd`. |
| `<leader>ss/sn/sp/sa/s?` | Normal | Spell toggles (`setlocal spell`, siguiente/anterior sugerencia, marcar palabra, sugerencias). |
| `<Leader>m` | Normal | Limpia `^M`. |
| `<leader>n` | Normal | `NERDTreeToggle`. |
| `<leader>w` | Normal | Guardar archivo. |
| `<leader>xx/xq/xl` | Normal | Diagnostics (CocList/quickfix/location). |
| `<leader>uw/ul/ur/us` | Normal | Toggles wrap, number, relativenumber, spell. |
| `<leader>cs` | Normal | Outline (CocList). |
| `<leader>cf` | Normal | Formatea con CoC. |
| `<leader>ca` | Normal/Visual | Code actions (CoC). |
| `[d` / `]d` | Normal | Diagnóstico previo / siguiente (CoC). |
| `gd` / `gD` / `gi` / `gt` / `gr` | Normal | Navegación LSP (CoC). |
| `K` | Normal | Hover (CoC). |
| `<F2>` | Normal | Rename (CoC). |
| `inoremap <C-Space>` / `<C-k>` | Insert | Refrescar sugerencias CoC. |
| `inoremap <CR>` | Insert | Confirma completado (CoC). |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` / `Ctrl+PageDown/PageUp` | Normal | Navegación de buffers. |
| `Alt+j/k` (normal/insert/visual) | Mover líneas/bloques. |
| `Shift+Alt+j/k` | Duplica líneas/selecciones. |
| `inoremap jj` | Insert | Salir a normal. |
| `0` | Normal | Remapeado a `^` (primer carácter no blanco). |
| `Visual *` / `Visual #` | Busca selección hacia delante / atrás. |
| `<Esc>` | Normal | Limpia highlight (`nohlsearch`). |
| `WhichKey (<leader>)` | Normal | Muestra menú de mapeos. |
| `tnoremap <Esc>` / `Ctrl+`` | Terminal | Salir a normal / toggle Floaterm. |
| `Ctrl+/` | Normal/Visual | Comentarios (Commentary). |
| `Ctrl+a` | Normal | Seleccionar todo (`ggVG`). |
| `Ctrl+s` (fuera tmux) | Normal/Visual | Guardar. |
| `Ctrl+w` (fuera tmux) | Normal | Cerrar buffer actual. |
| `F5/F10/F11/Shift+F11/F9` | Normal | Controles de Vimspector (continuar, step, breakpoint). |
| `]h` / `[h` / `<leader>hs/hr/hp/hd/hb` | Normal | GitGutter (hunks, blame, diff). |

#### Otros

**Polybar / Dunst**: clicks definidos en la barra (`config/polybar/config.ini`) abren scripts: icono de micro (`click izquierdo` = mute/unmute), módulo de actualizaciones (`click izq` abre script de actualización, derecho lanza notificación). Dunst scripts usan `dunstctl` sin teclas dedicadas.

### Funciones personalizadas / Custom functions

| Función | Archivo | Descripción breve |
| ------- | ------- | ----------------- |
| `_req` | `bash/bash_lib/core.sh` | Verifica que los comandos requeridos existan antes de ejecutar la función. |
| `_edit_at` | `bash/bash_lib/core.sh` | Abre archivo (y opcionalmente línea) en editor respetando `$VISUAL`/`$EDITOR`. |
| `fkill` | `bash/bash_lib/core.sh` | Mata procesos seleccionados vía `fzf` con confirmaciones y fallback a SIGKILL. |
| `rgf` | `bash/bash_lib/core.sh` | Busca con `rg` + `fzf` y abre coincidencias en editor en la línea exacta. |
| `t` | `bash/bash_lib/core.sh` | Adjunta o crea sesión tmux con nombre dado (por defecto `main`). |
| `trash` | `bash/bash_lib/core.sh` | Envía archivos a la papelera usando `trash-put`. |
| `redo` | `bash/bash_lib/core.sh` | Repite el penúltimo comando del historial (evitando bucles). |
| `_have_compose` | `bash/bash_lib/docker.sh` | Comprueba disponibilidad de `docker compose` o `docker-compose`. |
| `_docker_compose` | `bash/bash_lib/docker.sh` | Ejecuta `docker compose` usando v1 o v2 según disponibilidad. |
| `_cd_repo_root_if_compose` | `bash/bash_lib/docker.sh` | Cambia a la raíz del repo si contiene `docker-compose.yml`. |
| `docps` | `bash/bash_lib/docker.sh` | Lista servicios activos con `docker compose ps`. |
| `dlogs` | `bash/bash_lib/docker.sh` | Selecciona servicio con `fzf` y hace `logs -f` tail 200. |
| `dsh` | `bash/bash_lib/docker.sh` | Abre shell interactiva (`bash`/`sh`) en servicio en ejecución. |
| `dclean` | `bash/bash_lib/docker.sh` | Ejecuta `docker system prune` tras confirmación explícita. |
| `fo` | `bash/bash_lib/nav.sh` | Busca archivos/dirs con `fd` + `fzf`, abre o `cd`. |
| `cdf` | `bash/bash_lib/nav.sh` | Navega a directorios recientes vía `zoxide`. |
| `take` | `bash/bash_lib/nav.sh` | `mkdir -p` + `cd` en una sola orden. |
| `extract` | `bash/bash_lib/nav.sh` | Descomprime archivo según extensión (tar, zip, 7z, etc.). |
| `cb` | `bash/bash_lib/nav.sh` | Copia entrada (stdin/args/archivo) al portapapeles (wl-copy/xclip/pbcopy). |
| `_git_root_or_die` | `bash/bash_lib/git.sh` | Asegura que se está dentro de un repo git. |
| `_git_main_branch` | `bash/bash_lib/git.sh` | Detecta rama principal (`main/master/origin/HEAD`). |
| `_git_switch` | `bash/bash_lib/git.sh` | Cambia de rama usando `git switch` o `checkout`. |
| `_git_switch_new` | `bash/bash_lib/git.sh` | Crea y cambia a nueva rama desde ref dada. |
| `grt` | `bash/bash_lib/git.sh` | Hace `cd` a la raíz del repo. |
| `gbr` | `bash/bash_lib/git.sh` | Selecciona rama (local/remota) con `fzf`, crea tracking si hace falta. |
| `gstaged` | `bash/bash_lib/git.sh` | Muestra diff staged (color). |
| `gundo` | `bash/bash_lib/git.sh` | Reset soft del último commit con confirmación. |
| `gcof` | `bash/bash_lib/git.sh` | Cambia de rama local con preview de historial. |
| `gclean` | `bash/bash_lib/git.sh` | Borra ramas locales mergeadas tras confirmar. |
| `watchdiff` | `bash/bash_lib/git.sh` | Monitoriza status/diff en loop cada 2s. |
| `checkpoint` | `bash/bash_lib/git.sh` | Guarda stash con mensaje legible (incluye untracked). |
| `wip` | `bash/bash_lib/git.sh` | Crea commit WIP con timestamp (tras `git add -A`). |
| `fixup` | `bash/bash_lib/git.sh` | Genera `commit --fixup` contra `HEAD`. |
| `recent` | `bash/bash_lib/git.sh` | Selecciona archivo modificado recientemente y lo abre. |
| `gp` | `bash/bash_lib/git.sh` | Push con confirmación y creación de upstream si falta. |
| `br` | `bash/bash_lib/git.sh` | Lista ramas (locales/remotas) ordenadas por actividad. |
| `fhist` | `bash/bash_lib/misc.sh` | Navega historial con `fzf` y permite re-ejecutar. |
| `todo` | `bash/bash_lib/misc.sh` | Lista o añade entradas en `~/.todo.cli.txt`. |
| `bench` | `bash/bash_lib/misc.sh` | Cronometra ejecución de un comando (ms). |
| `envswap` | `bash/bash_lib/misc.sh` | Lista/activa `.env.<nombre>` con backup y permisos 600. |
| `r` | `bash/bash_lib/misc.sh` | Edita el último comando y lo ejecuta opcionalmente en shell actual. |
| `ports` | `bash/bash_lib/misc.sh` | Lista puertos en escucha (via `ss` o `lsof`). |
| `topme` | `bash/bash_lib/misc.sh` | Filtra procesos relevantes (php/node/docker…) por CPU. |
| `tt` | `bash/bash_lib/misc.sh` | Temporizador interactivo simple. |
| `move_to_end` | `bash/bashrc` | Reordena `$PATH` enviando ruta indicada al final. |
| `usage` | `scripts/bootstrap.sh` | Muestra ayuda del bootstrap. |
| `note` | `scripts/bootstrap.sh` | Loguea mensajes informativos. |
| `die` | `scripts/bootstrap.sh` | Aborta con mensaje de error. |
| `act` | `scripts/bootstrap.sh` | Ejecuta comando respetando modo `--dry-run`. |
| `backup_path` | `scripts/bootstrap.sh` | Guarda backup de destino antes de enlazar. |
| `link_to` | `scripts/bootstrap.sh` | Crea symlink (backup + manifest). |
| `pick_manifest` | `scripts/rollback.sh` | Resuelve manifest a usar (`latest` o timestamp). |
| `join_by_slash` | `tmux/scripts/shorten_path.sh` | Une componentes con `/` manteniendo formato. |
| `shorten_keep_last_two` | `tmux/scripts/shorten_path.sh` | Abrevia rutas dejando los dos últimos directorios completos. |
| `collapse_to_ellipsis_last` | `tmux/scripts/shorten_path.sh` | Reduce ruta a `.../basename` cuando es demasiado larga. |
| `cpu_col`, `temp_col`, `load_col`, `mem_col`, `net_col` | `tmux/scripts/status_pill.sh` | Devuelven color tmux según umbrales de métrica. |
| `rt_dir` | `tmux/scripts/status_pill.sh` | Determina directorio runtime (`XDG_RUNTIME_DIR` o `/tmp`). |
| `pad_pct`, `fmt_temp` | `tmux/scripts/status_pill.sh` | Formatea porcentajes / temperatura. |
| `cpu_pct` | `tmux/scripts/status_pill.sh` | Calcula uso CPU (%) con delta `/proc/stat`. |
| `cpu_temp_c` | `tmux/scripts/status_pill.sh` | Obtiene temperatura CPU (sensors o sysfs). |
| `load_pct` | `tmux/scripts/status_pill.sh` | Normaliza load average respecto a nº de CPU. |
| `mem_pct` | `tmux/scripts/status_pill.sh` | Calcula % memoria usada (MemTotal vs MemAvailable). |
| `is_wireless_iface` | `tmux/scripts/status_pill.sh` | Detecta si interfaz es Wi-Fi. |
| `nm_ssid_for` | `tmux/scripts/status_pill.sh` | Obtiene SSID vía nmcli/iw. |
| `choose_ifaces` | `tmux/scripts/status_pill.sh` | Selecciona interfaces activas (ethernets/Wi-Fi). |
| `net_rates` | `tmux/scripts/status_pill.sh` | Calcula RX/TX Ki/s y estado de red (E/W). |
| `human_rate_fixed` | `tmux/scripts/status_pill.sh` | Formatea tasas de red con ancho fijo. |
| `to_gi`, `pct` | `tmux/scripts/mem_human.sh` | Convierte KiB→GiB y calcula % usado. |
| `norm` | `tmux/scripts/load_avg.sh` | Normaliza carga por CPU. |
| `count_desc` | `tmux/scripts/pane_jobs.sh` | Cuenta procesos hijos reales de un pane. |
| `choose_if` | `tmux/scripts/net_kis.sh` | Determina interfaz de red prioritaria. |
| `human` | `tmux/scripts/net_kis.sh` | Formatea tasas de red (definida dentro del script). |
| `get_formatted_speed` | `config/polybar/scripts/speedtest.sh` | Convierte velocidades de speedtest a unidades legibles. |
| `esc`, `nonblock_read`, `main` | `vim/vim/autoload/plug.vim` | Funciones internas de vim-plug (archivo vendor incluido sin modificaciones). |

> Nota: `vim/autoload/plug.vim` contiene muchas más funciones auxiliares (`plug#...`). Dado que es código externo (vim-plug), se remite a su documentación oficial para detalle completo.

### Alias

| Alias | Comando expandido | Descripción / Notas |
| ----- | ----------------- | ------------------- |
| `..` / `...` | `cd ..` / `cd ../..` | Navegación rápida de directorios. |
| `gs` | `git status -sb 2>/dev/null || git status` | Status breve con fallback si `-sb` no soportado. |
| `gc` / `gcm` | `git commit` / `git commit -m` | Accesos directos a commit. |
| `gup` | `git pull --rebase --autostash` | Pull que rebasea y guarda cambios sin staged. |
| `gfa` | `git fetch --all --prune` | Actualiza remotos y elimina referencias obsoletas. |
| `gpf` | `git push --force-with-lease` | Push forzado seguro. |
| `gl` | `git log --oneline --graph -n 30` | Historial compacto. |
| `gd` | `git diff --color=always \| bat --pagging=always --plain --color=always 2>/dev/null || git diff` | Diff coloreado vía `bat`; **typo `--pagging` rompe la opción, ver Observaciones**. |
| `gds` | `git diff --cached ... \| bat --paging=always ... || git diff --cached` | Diff staged coloreado. |
| `ga` | `git add -A` | Añade todo. |
| `gco` | `git checkout` | Alias clásico. |
| `gsw` | `git switch` | Cambio de rama. |
| `lg` | `lazygit` (si está instalado) | UI TUI para Git que respeta los hooks globales (`~/.git-hooks`). No reemplaza `git lg` (alias de `gitalias`). |
| `l0` | `\ls --color=auto` | LS «clásico» cuando se redefine `ls`. |
| `ls` | Si existe `eza`: `eza --group-directories-first --icons=auto --color=auto --sort newest -la`; si no, `ls --color=auto`. | Listado enriquecido. |
| `ll` | `eza -lh --git ...` o `ls -alh --color=auto` | Listado detallado. |
| `la` | `eza -a ...` o `ls -A --color=auto` | Incluye ocultos. |
| `dc` / `dcb` / `dcp` / `dcu` / `dcud` / `dcd` / `dcr` | `docker compose` (varias subcomandos) | Atajos compose v2 (solo si docker existe). |
| `dcps` | `docker compose ps` | Lista servicios. |
| `dps` | `docker ps -a --format "table ..."` | Tabla de contenedores. |
| `dcl` / `dclf` / `dce` | Logs, logs -f y exec (compose). |
| `cat` | `bat -p --paging=never` (si `bat` está disponible) | `cat` coloreado. |
| `grep` / `rgrep` | `grep --color=auto` / `rg --color=auto` | Búsqueda coloreada. |
| `vim` / `n` | `nvim` (si existe) | Forzar uso de Neovim. |
| `cls` | `clear` | Limpiar terminal. |
| `reload` | `source ~/.bashrc` | Recarga configuración de bash. |
| `path` | `echo "$PATH" \| tr ":" "\n"` | Lista `$PATH` línea a línea. |
| `help` | `tldr` (si está instalado) | Cheatsheets concisos. |

**Git (`git/gitalias`)**

| Alias | Acción |
| ----- | ------ |
| `co` | `git checkout`. |
| `br` | `git branch`. |
| `ci` | `git commit`. |
| `st` | `git status -sb`. |
| `lg` | Log gráfico `--pretty` (hash, mensaje, autor relativo). |
| `last` | `git log -1 HEAD --stat`. |
| `undo` | `git reset HEAD~1 --mixed`. |
| `df` | `git diff`. |
| `dc` | `git diff --cached`. |
| `cp` | `git cherry-pick`. |
| `type` | `git cat-file -t`. |
| `dump` | `git cat-file -p`. |

### Observaciones / Warnings

- **tmux navegación `Ctrl+h/j/k/l`:** el fallback cuando no se detecta Vim usa `select-pana` (faltan letras). Esto provoca error y no mueve el foco (`tmux/tmux.conf`, líneas 46-49). Sustituir por `select-pane` corrige el problema.
- **Alias `gd`:** la opción `--pagging` está mal escrita (`bash/bash_aliases`). `bat` ignora la opción y puede fallar; debería ser `--paging`.
- **Redundancias menores:**
  - En Neovim los mappings `Ctrl+h/j/k/l` se definen tanto en `config/keymaps.lua` como en `plugins/tmux-navigator.lua`; aunque redundantes, apuntan al mismo comando.
  - En i3 existen tanto `$mod+$left` (usando variables h/j/k/l) como `$mod+Left`; ambas combinaciones funcionan y pueden verse como duplicadas.

---

## English

The tables above use bilingual headers (`Atajo / Shortcut`, `Descripción / Action`). They apply equally in English. Refer to the Spanish section for the full authoritative list of shortcuts, functions, aliases and warnings.
