# CHANGELOG

Todas las modificaciones relevantes del entorno (i3 • tmux • (Neo)Vim).
Formato: entradas fechadas (YYYY-MM-DD), estilo “Keep a Changelog” simplificado.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
  - `i3-msg -t get_bindings | grep -E '"(Mod4\\+z|Mod4\\+f|Mod4\\+Shift\\+(Left|Right|Up|Down))"'`
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

---

## Histórico anterior

> Este es el primer changelog formal de la serie “alineado a tmux”.

# Changelog

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
