# EXTENDING.md - Cómo extender la configuración

## Añadir un nuevo plugin

1. Crea `lua/plugins/<nombre>.lua` usando `lua/plugins/_template_plugin.lua` como base.
2. Usa **solo una fuente de la verdad** para:
  - Keys -> definidas en el propio spec del plugin.
  - Comandos -> en `cmd = { ... }` si disparan la carga.
3. Ejecuta `:Lazy sync` y comprueba:
  - No hay errores en `:messages`.
  - Los atajos se ven en `which-key`.
4. Añade una entrada en `PLUGINS.md` con:
  - Nombre
  - Rol
  - Atajos relevantes si los hay.

## Añadir soporte para un nuevo lenguaje

1. Crea `lua/lang/<lenguaje>.lua` a partir de `lua/lang/_template_lang.lua`.
2. Rellena:
  - `M.lsp` (server de `mason-lspconfig`+ `lspconfig`).
  - `M.format.formatters` (para `conform.nvim`).
  - `M.lint.linters` (para `nvim-lint`).
  - Opcional: `M-tests` (neotest) y `M.tasks` (Overseer).
3. Registra el lenguaje en:
  - `lua/plugins/lsp.lua` -> lista de lenguajes a cargar.
  - `lua/plugins/format_lint.lua` -> lista `languages = { ... }` si es estática.
4. Ejecuta:
  - `:Mason` -> instala LSP/formatters/linters necesarios.
  - `:LspInfo`, `:ConformInfo`, `:Lint` -> valida que todo responde
5. Si añades atajos nuevos, actualiza `SHORTCUTS.md`.
