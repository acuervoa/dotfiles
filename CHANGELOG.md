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
