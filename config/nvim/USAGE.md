# Guía de uso de la configuración Neovim

## Primer arranque

- Clona el repo (o sincroniza tu fork) y arranca con `NVIM_APPNAME=acuervoa/dotfiles/config/nvim nvim` para aislar la configuración del resto de tu sistema.
- En la primera sesión ejecuta los mantenimientos básicos:
  - `:Lazy sync` para instalar/actualizar plugins (usa `:Lazy restore` si quieres ceñirte al `lazy-lock.json` versionado).
  - `:Mason` para revisar/instalar lenguajes, LSPs y adaptadores DAP.
  - `:CheckHealth` para validar dependencias externas (node, php, docker, etc.).
- Revisa los atajos globales en [`SHORTCUTS.md`](../../SHORTCUTS.md) y las asignaciones base en [`lua/config/keymaps.lua`](lua/config/keymaps.lua) para que tmux/i3/kitty y Neovim se comporten igual.

## Atajos esenciales

- Navegación y edición diaria: `<Alt-h/l>` mueve el foco entre ventanas nvim, `<Alt-j/k>` sube/baja líneas o bloques, `<leader>q` cierra la ventana actual y `<leader>w` guarda el buffer. Todas estas teclas viven en [`lua/config/keymaps.lua`](lua/config/keymaps.lua) y están resumidas en la tabla de NeoVim en [`SHORTCUTS.md`](../../SHORTCUTS.md#neovim-confignvim).
- Gestión de diagnósticos y código LSP: usa `gd`/`<F12>` para saltar a definiciones, `K` para *hover*, `<F2>` para renombrar y `<leader>ca` para acciones de código, asignados al adjuntarse un servidor LSP en [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua).
- Depuración con DAP: `F5` inicia/continúa, `<leader>d0/dI/dU` controlan *step over/into/out*, `F9` o `<leader>db` alternan *breakpoints* y `<leader>du` abre/cierra el panel UI de DAP según [`lua/plugins/dap.lua`](lua/plugins/dap.lua).
- Formateo y linting: `<leader>cf` lanza `conform.nvim` (respeta *format on save*), y `ConformInfo` muestra los *formatters* activos. Se definen en [`lua/plugins/format_lint.lua`](lua/plugins/format_lint.lua).
- Ejecución de tareas con Overseer: `<leader>ot` alterna la lista y `<leader>or` abre las plantillas registradas (tests/QA para proyectos PHP + mise) según [`lua/plugins/tasks.lua`](lua/plugins/tasks.lua).

## Workflows

### LSP

1. Asegúrate de tener los servidores deseados en `:Mason` (la lista inicial está en `lua/plugins/lsp.lua`).
2. Abre un buffer del lenguaje; al adjuntarse el LSP tendrás *hover*, rename, *code actions* y navegación con las teclas anteriores.
3. Usa `:Outline` (`<leader>cs`) para ver símbolos si el servidor los expone.

### DAP

1. Instala el adaptador con `:Mason` (p. ej. *php-debug-adapter* para Xdebug).
2. Coloca *breakpoints* con `F9` o `<leader>db`; `:lua require"dap".list_breakpoints()` te permite revisarlos.
3. Ejecuta `F5` o `<leader>dc` para lanzar/adjuntarte y abre la UI (`<leader>du`) para ver *stacks*, scopes y REPL.

### Overseer

1. Lanza `:OverseerToggle` (`<leader>ot`) para abrir el panel inferior.
2. Ejecuta una plantilla con `:OverseerRun` o `<leader>or`; los comandos PHP se activan sólo si el proyecto tiene `composer.json` y `.mise.toml`.
3. Revisa el historial de tareas en el panel y vuelve a lanzar con `:OverseerTaskAction` si es necesario.

### conform.nvim

1. Usa `<leader>cf` para formatear manualmente el buffer actual (o selección en modo visual).
2. *Format on save* está activo salvo que `vim.g.disable_autoformat` o `vim.b[buf].disable_autoformat` estén a `true`; puedes alternarlo con `:FormatToggle`.
3. Consulta los *formatters* disponibles por tipo de archivo con `:ConformInfo`.

## Mantenimiento y troubleshooting

- **Sincronizar plugins:** `:Lazy sync` (útil tras actualizar el repo). Si algo falla, `:Lazy clean` elimina plugins huérfanos.
- **Reinstalar dependencias:** abre `:Mason` y reintala/adiciona LSPs, DAPs o linters.
- **Salud del entorno:** `:CheckHealth` muestra binarios faltantes o problemas de *runtime*.
- **Resetear el lock de plugins:** elimina `config/nvim/lazy-lock.json` y ejecuta `:Lazy sync` para regenerarlo. Si quieres volver al *lock* versionado, usa `git checkout -- config/nvim/lazy-lock.json` y luego `:Lazy restore`.
- **Logs de errores:** revisa `:messages` y los ficheros en `:echo stdpath('state') .. '/lazy'` cuando un plugin no se carga correctamente.
