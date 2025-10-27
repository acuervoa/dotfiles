# CHANGELOG

Todas las modificaciones relevantes del entorno (i3 • tmux • (Neo)Vim).
Formato: entradas fechadas (YYYY-MM-DD), estilo “Keep a Changelog” simplificado.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2025-10-29 — Rollback robusto y Polybar consciente de monitores

### Cambiado
- `config/polybar/launch.sh`: el _launcher_ detecta monitores conectados con `xrandr`, respeta el primario (o cae al primero disponible) y solo lanza las barras necesarias (`main` + `secondary`).

### Corregido
- `scripts/rollback.sh`: selección segura del manifest más reciente (`latest`) aun cuando no existan archivos, mensajes claros cuando faltan manifests/backups y omisión de paquetes `stow` inexistentes.

## 2025-10-28 — Documentación alineada con git-hooks

### Cambiado
- `README.md`: se documenta la ruta real `git/git-hooks` y el uso de `~/.git-hooks` (enlazada por `bootstrap.sh`) para los hooks compartidos.
- Verificación rápida actualizada (`test -x ~/.git-hooks/*`).

## 2025-10-27 — Modularización Bash, fixes y atajos

### Añadido
- **Librería Bash modular** en `~/.bash_lib/` dividida en:
  - `core.sh`: `_req`, `_edit_at`, `fkill`, `rgf`, `t`, `trash`, `redo`.
  - `git.sh`: `gbr`, `gcof`, `gclean`, `gp`, `watchdiff`, `recent`, `wip`, `fixup`, etc.
  - `docker.sh`: `_docker_compose` (v1/v2), `docps`, `dlogs`, `dsh`.
  - `nav.sh`: `fo`, `cdf`, `take`.
  - `misc.sh`: `fhist`, `todo`, `bench`, `envswap`, `r`, `ports`, `topme`, `tt`, `extract`, `cb`.
- Documentación actualizada: `README.md`, `README-BOOTSTRAP.md`, `SHORTCUTS.md`, `CONTRIBUTING.md`.

### Cambiado
- `~/.bashrc` pasa a **carga modular** (sourcing de `~/.bash_lib/*.sh`) en lugar de `.bash_functions` monolítico.
- Ajustes de entorno: `stty -ixon`, `set -o vi`, FZF defaults (con `rg`/`fd`), integración `zoxide`, `starship`, `fnm`.

### Corregido
- `fhist`: typo `printf` (antes `prinf`) y deduplicación estable.
- `cb`: detección correcta de **stdin piped** vs args; soporta `wl-copy`, `xclip`, `pbcopy`.
- `bench`: cronometraje estable (ms) con _fallback_ portable.
- `ports`: alineado con `ss`/`lsof` y cabeceras consistentes.
- `docker`: detección robusta de `docker-compose` v1 y `docker compose` v2; `cd` a raíz del repo si hay compose.
- Funciones `g*` (git): validaciones y previews fzf consistentes.

### Deprecated / Eliminado
- Uso directo de `.bash_functions` → **reemplazado** por `~/.bash_lib/*.sh`.

### Migración
1. Comenta la carga de `.bash_functions` en `~/.bashrc`.
2. Añade:
   ```bash
   [ -f "$HOME/.bash_lib/core.sh"   ] && . "$HOME/.bash_lib/core.sh"
   [ -f "$HOME/.bash_lib/git.sh"    ] && . "$HOME/.bash_lib/git.sh"
   [ -f "$HOME/.bash_lib/nav.sh"    ] && . "$HOME/.bash_lib/nav.sh"
   [ -f "$HOME/.bash_lib/docker.sh" ] && . "$HOME/.bash_lib/docker.sh"
   [ -f "$HOME/.bash_lib/misc.sh"   ] && . "$HOME/.bash_lib/misc.sh"
   ```

## 2025-10-26

### Añadido

- **Shell helpers** en `~/.bash_functions`:
  - Navegación/edición: `fo`, `cdf`, `rgf`, `recent`, `_edit_at`.
  - Git TUI: `gcof`, `gbr`, `gstaged`, `gundo`, `gclean`, `checkpoint`, `wip`, `fixup`, `watchdiff`, `grt`.
  - Docker helpers: `docps`, `dlogs`, `dsh`.
  - Utilidades: `fkill`, `cb`, `fhist`, `take`, `extract`, `t`, `ports`, `topme`, `r`, `tt`, `trash`, `bench`, `redo`, `envswap`, `todo`.
- **Hooks de Git** (reproducibles vía `core.hooksPath`):
  - `pre-commit`: escaneo de trazas (`console.log`, `var_dump`, etc.), bloqueo de ficheros sensibles (`.env*`, `docker-compose.override.yml`).
  - `commit-msg`: rechazo de commits con `WIP/tmp`.

### Corregido

- `gundo`: typo `returno` → `return`.
- `dsh`: typo `docke -compose` → `docker-compose`.
- `grt`: mensaje corregido.
- `watchdiff`: variable inexistente `$s` → mostrar rama real; mensaje y límite de líneas coherente.
- `bench`: _fallback_ a `awk` si no hay `bc`.

### Documentación

- `README.md`: se añaden dependencias (`fd`, `fzf`, `ripgrep`, `bat`, `eza`, `zoxide`, `wl-clipboard`/`xclip`, `trash-cli`, `docker`, `docker-compose`, `bc`) y guía de instalación/uso de hooks.

## [2025-10-25] – Navegación Vim/Neovim ↔ tmux con <C-h/j/k/l>

**Ámbito**: unificar la navegación entre _splits_ de Vim/Neovim y paneles tmux usando las mismas teclas.

### Added

- **Neovim**: se añade el plugin `christoomey/vim-tmux-navigator` vía _lazy.nvim_ con carga inmediata (`lazy = false`).
  - Variables: `g:tmux_navigator_no_mappings = 1`, `g:tmux_navigator_disable_when_zoomed = 1`.
  - Archivo nuevo: `~/.config/nvim/lua/plugins/tmux-navigator.lua`.
- **Vim (clásico)**: se añade `christoomey/vim-tmux-navigator` vía _vim-plug_.
- **tmux**: se incluyen _bindings_ inteligentes (**sin prefijo**) para `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` que:
  - Detectan si el _pane_ corre (n)vim y reinyectan las teclas; si no, mueven el foco entre paneles.
  - Se habilita `set -g focus-events on` para una mejor integración con Neovim.

### Changed

- **Neovim**: se sustituyen los mapas de navegación de ventanas de `<C-w>h/j/k/l` por los comandos `:TmuxNavigate{Left,Down,Up,Right}` en `~/.config/nvim/lua/config/keymaps.lua`.
- **Vim**: se añaden _mappings_ equivalentes en `~/.vimrc` para mantener paridad con Neovim.
- **tmux**: se actualiza `~/.tmux.conf` con el _snippet_ “smart pane switching” y _bindings_ `-n` (sin prefijo) para `<C-h/j/k/l>`.

### Fixed

- Navegación inconsistente entre _splits_ de (Neo)Vim y paneles tmux.
- Pérdida de _zoom_ en tmux al moverse desde Neovim (se evita con `g:tmux_navigator_disable_when_zoomed = 1`).

### Breaking changes

- **Ninguna**. Los cambios son aditivos y los _bindings_ tmux nuevos no interfieren con el _prefix_ existente (`C-s`).

### Migration / Notas de actualización

1. Instalar/actualizar plugins:
   ```bash
   # Neovim (lazy.nvim)
   nvim --headless "+Lazy! sync" +qa
   # Vim (vim-plug)
   vim +PlugInstall +qall
   ```

## 2025-10-19 — Unificación de atajos alineada a tmux (prefijo Ctrl-s)

### Added

- **tmux**
  - `prefix+q` → `kill-pane` (cerrar pane actual).
  - `prefix+f` → `find-window` (buscador por nombre/título).
- **i3**
  - `$mod+f` → `rofi -show window` (finder de ventanas; paridad con `prefix+f`).
  - `$mod+z` → `fullscreen toggle` (zoom; análogo a `Z` en tmux).
  - Redimensionado con `$mod+Shift+←/→/↑/↓`.
- **Neovim**
  - `<leader>"` → `:split` (split horizontal; espejo de `"` en tmux).
  - `<leader>%` → `:vsplit` (split vertical; espejo de `%` en tmux).
  - `<leader><BS>` → `:only` (cerrar otras ventanas; análogo a `kill-pane -a`).
  - `<leader>s` → selector de buffer (paralelo a _choose-tree_).
  - `<leader>w` → `:w` (guardar; útil dentro de tmux donde `<C-s>` es prefijo).
  - `Alt+Shift+←/→/↑/↓` → resize de ventana (además de `Ctrl+Flechas` ya existente).

### Changed

- **i3**
  - **`$mod+f` deja de ser fullscreen** y pasa a ser **finder** (Rofi). El **fullscreen** se mueve a **`$mod+z`** para reflejar el **`Z`** (zoom) de tmux.
- **Norma de diseño**
  - Se prioriza nomenclatura de **tmux** como “fuente de verdad”: mismas letras implican la misma intención entre capas (p. ej., **f = find**, **z = zoom/fullscreen**, **" / % = splits**).

### Fixed

- **Neovim**: mapeo de `<C-f>` — se corrige el uso de `vim.api.nvim_replace_termcodes` (antes: `nvim_replace_termcoders`), haciendo que `<C-f>` abra el prompt de `/` en _normal/insert/visual_.

### Deprecated

- **Neovim**: se mantienen por compatibilidad `<leader>sh` / `<leader>sv`, pero se **recomienda** migrar a `<leader>"` / `<leader>%` para paridad con tmux.

### Removed

- Nada.

### Security

- N/A.

### Notas de migración

1. **Guardar dentro de tmux**: `<C-s>` es prefijo; usa **`<leader>w`** o `:w` en Neovim cuando estés dentro de tmux.
2. **Pantalla completa en i3**: ahora es **`$mod+z`** (antes `$mod+f`). El **finder** de ventanas está en **`$mod+f`**.
3. **Splits “estilo tmux” en Neovim**: usa `<leader>"` y `<leader>%` (puedes seguir usando `:split/:vsplit` o `<leader>sh/sv` temporalmente).
4. **Resize**:
   - **tmux**: `Alt+Shift+Flechas` (global) y `prefix+Ctrl+Flechas` (pane granular).
   - **i3**: `$mod+Shift+Flechas`.
   - **Neovim**: `Ctrl+Flechas` y **Alt+Shift+Flechas**.

### Validación rápida

- **tmux**
  - `tmux list-keys | grep -E 'bind-key q kill-pane|find-window'` → deben aparecer los nuevos binds.
  - Probar: `prefix+q`, `prefix+f`, `prefix+"`, `prefix+%`, `Alt+Shift+Flechas`.
- **i3**
  - `i3-msg -t get_bindings | grep -E '"(Mod4\+z|Mod4\+f|Mod4\+Shift\+(Left|Right|Up|Down))"'`
  - Probar: `$mod+z` (fullscreen), `$mod+f` (Rofi window), `$mod+Shift+Flechas` (resize).
- **Neovim**
  - `:verbose map <C-f>` → debe mostrar el mapping al prompt de `/`.
  - `:verbose nmap <leader>"`, `<leader>%`, `<leader><BS>`, `<leader>s`, `<leader>w` → deben existir.
  - Probar Alt+Shift+Flechas y Ctrl+Flechas.

### Referencia de parches aplicados (resumen)

- **tmux**: añade `bind q kill-pane` y `bind f command-prompt 'find-window "%%"'`.
- **i3**: reasigna fullscreen a `$mod+z`; `$mod+f` abre Rofi; añade `$mod+Shift+Flechas` para resize.
- **Neovim**: corrige `<C-f>`; añade `<leader>"`, `<leader>%`, `<leader><BS>`, `<leader>s`, `<leader>w` y resize con Alt+Shift+Flechas.

### Riesgos conocidos

- **Secuencias de Alt+Shift+Flechas** pueden variar según terminal; en _Kitty_ funcionan correctamente. Si no funcionan, usar solo `Ctrl+Flechas`.
- Cambio de hábito: `$mod+f` ya no es fullscreen (ver “Notas de migración” #2).

## [2025-10-19] - Audit: estabilidad, tema y atajos

### Added

- Changelog inicial/actualizado para seguimiento de cambios.
- Neovim: atajos extra `Alt+h` / `Alt+l` para moverse entre ventanas (paridad visual con tmux).

### Changed

- Polybar: paleta unificada a Catppuccin Mocha para coherencia con kitty/tmux.
- Neovim: compatibilidad de `lazy.lua` con `vim.uv` / `vim.loop`.

### Fixed

- Polybar: corrección en `module/speedtest` (se quitó `:wq` en `exec-if`).
- Kitty: eliminación de `blur true` (no soportado por kitty; el blur lo hace el compositor).
- Neovim: retirada de `o.winborder` (opción global inválida que lanzaba error).
- Picom: desactivadas animaciones de forks y limpiados parámetros de blur redundantes.

### Notes

- Si usas un fork de picom con animaciones, puedes reactivar el bloque y medir latencia/tearing.
- Próxima iteración: alinear i3 y tmux al 100% con el esquema Mod / Alt / Ctrl.
