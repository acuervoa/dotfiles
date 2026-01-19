# Neovim config (VSCode-like)

Configuración de Neovim orientada a desarrollo diario (PHP, Bash, Lua, Go, Rust, Python) con foco en:

- LSP moderno (API 0.11+), autocompletado y diagnósticos integrados.
- Formateo y lint centralizados por lenguaje.
- Tests (neotest), debug (DAP), tareas (Overseer).
- Navegación rápida tipo VSCode (Telescope, neo-tree, Outline, Trouble).

Requisitos mínimos:

- Neovim **0.11+** (por la API nueva de LSP).
- Node.js, PHP, Go, Rust, Python según los lenguajes que se usen.
- Herramientas externas instaladas vía `mason.nvim`, sistema o `mise`.

`runtime` principal: `~/.config/nvim`
`<leader>` = barra espaciadora (`" "`)

---

## 1. Infraestructura y dependencias

### Núcleo

- **folke/lazy.nvim**
  Gestor de plugins. Se carga en `init.lua` y resuelve todo el árbol de `lua/plugins/`.

- **nvim-lua/plenary.nvim**
  Librería de utiliddes para muchos plugins (Telescope, neotest, gitsigns, Spectre...).

- **nvim-tree/nvim-web-devicons** + **echasnovski/mini.icos**
  Iconos de archivos unificados en barra de buffers, explorador, Telescope, etc.

- **MunifTanjim/nui.nvim**
  Componentes de UI (ventanas, popups) usados y principalmente por `neo-tree.nvim`.

- **nvim-neotest/nvim-nio**
  Infraestructura async usada por `nvim-dap-ui` y otros plugins.

- **antoinemadec/FixCursorHold.nvim**
  Fix para el evento `CursorHold` (evita flicker y problemas con UIs lentas, neotest)

---

## 2. Apariencia y UI

- **Mofiqul/vscode.nvim**
  Tema de colores principal de tipo VSCode.
  Se configura en `lua/plugins/ui.lua` y se aplica en el arranque:
  - `:colorscheme vscode` para re-aplicarlo.

- **nvim-lualine/lualine.nvim**
  Statusline con información de modo, LSP, diagnósticos, etc.

- **akinsho/bufferline.nvim**
  Barra de buffers estilo "pestañas" con integración de diagnósticos.

- **lukas-reineke/indent-blankline.nvim**
  Lineas de indentación (`|`) con soporte Treesitter.

- **rcarriga/nvim-notify**
  Reemplaza `vim.notify` por notificaciones bonitas en ventana flotante-
  Atajo importante:
  - `<leader>uh` abre el histórico de notificaciones.

- **folke/which-key.nvim**
  Muestra un menú de combinaciones cuando pulsas `<leader>`.
  Usa `lua/plugins/which-key.lua` para agrupar atajos por tema (`<leader>b`, `<leader>f`, etc.).

- **utilyre/barbecue.nvim** + **SmithesP/nvim-navic**
  "Breadcrumbs" (ruta de símbolos) basada en LSP en la parte superior.

- **karb94/neoscroll.nvim**
  Scroll suave en movimientos grandes (`<C-d>`, `<C-u>`, etc.).

- **akinsho/toggleterm.nvim**
  Terminal flotante integrada:
  - `<C-\>` abre/cierra una terminal flotante.
  - `<leader>\` abre/cierra una terminal de "fallback".

---

## 3. Navegación, archivos y búsqueda

- **nvim-neo.tree/neo.tree.nvim**
  Explorador de archivs, buffers y estado Git.
  Atajos:
  - `<C-b>` -> toggle del panel izquierdo.
  - `<leader>e` -> foco en el explorador.

- **nvim-telescope/telescope.nvim**
  Buscador principal (ficheros, buffers, símbolos, comandos).
  Extensiones usadas:
  - `telescope-fzf-native.nvim` -> ordenación rápida nativa.
  - `telescope-ui-select.nvim` -> reemplaza `vim.ui.select`.
  - extension `notify` -> histórico de notificaciones.
  Atajos importantes:
  - `<C-p>` / `<leader>ff` -> buscar archivos.
  - `<leader>fg` -> búsqueda en todo el proyecto (ripgrep).
  - `<leader>fb` -> buffers.
  - `<leader>fr` -> archivos recientes.
  - `<leader>fs` -> símbolos de documento
  - `<leader>fn` -> histórico de notificaciones. 

- **nvim-pack/nvim-spectre**
  Búsqueda u reemplazo global en múltiples archivos.
  Atajos:
  - `<leader>sr` -> abrir Spectre global
  - `<leader>sw` -> buscar palabra bajo el cursor. 
  - `<leader>sp` -> buscar en el archivo actual.

- **hedyhli/outline.nvim**
  Vista de símbolos del LSP en un panel lateral (similar al Outline de VSCode).
  Atajo:
  - `<leader>cs` -> abrir/cerrar Outline.

- **folke/todo-comments.nvim**
  Resalta y lista `TODO`, `FIXME`, etc. Integrado con Trouble y Telescope.

- **folke/trouble.nvim**
  Panel unificado para diagnósticos, quickfix, loclist y TODOs.
  Atajos:
  - `<leader>xx` -> diagnósticos workspace.
  - `<leader>xd` -> diagnósticos del buffer.
  - `<leader>xq` -> quickfix
  - `<leader>xl` -> loclist
  - `<leader>xt` -> TODOs en Trouble.
  - `<leader>xT` -> TODOs en Telescope.

---

## 4. Movimiento y edición

- **folke/flash.nvim**
  Sustituye `f`/`F` por saltos inteligentes con resaltado.
  Atajos:
  - `f` (normal/visual/op-pending) -> salto con Flash.
  - `F` -> salto basado en Treesitter.

- **numToStr/Comment.nvim** + **JoosepAlviste/nvim-ts-context-commentstring**
  Comentado de líneas/bloques con soporte de lenguaje embebidos.
  Atajos:
  - `gc`, `gcc`, `gbc`, etc. (por defecto de Comment.nvim).
  - `<C-/>` en normal/visual -> toggle de comentario.

- **windwp/nvim-autopairs**
  Inserta y cierra paréntesis, comillas, etc. Integrado con `nvim-cmp`.

- **kylechui/nvim-surround**
  Añadir/cambiar/eliminar envolturas ( `()`, `[]`, `""`, etc.).

- **tpope/vim-sleuth**
  Detecta automáticamente indentación por archivo (`shiftwidth`, `expandtab`, etc.).

- **otavioschwanck/new-file-template.nvim**
  Aplica plantillas según tipo de archivo para nuevos ficheros (p.ej. boilerplate PHP, scripts, bash).
  Configurado en `lua/plugins/templates.lua` y `lua/templates/`.

---

## 5. Treesitter

- **nvim-treesitter/nvim-treesitter**
  Highligt, indentación y parsing incremental para múltiples lenguajes.

- **nvim-treesitter/nvim-treesitter-textobjects**
  Textobjects avanzados basados en AST (select alrededor de funciones, clases, etc.).

- **windwp/nvim-ts-autotag**
  Auto-cierre y actualización de etiquetas HTML/JSX.

- **MeanderiProgrammer/render-markdown.nvim** (opcional)
  Renderiza Markdown dentro de Neovim (encabezados, listas, tablas).
  Actualmente esta **deshabilitado** en la configuración -> se mantiene como experimento.

---

## 6. LSP, completado y ayudas al código

- **mason-org/mason.nvim**
  Gestor de binarios (LSP, DAP, linters, formatters) via UI `:Mason`.

- **mason-org/mason-lspconfig.nvim**
  `ensure_installed` de servidores LSP (PHP, Lua, Bash, tsserver, HTML, CSS, JSON, Docker, YAML, Go, Rust, Python...).

- **neovim/nvim.lspconfig**
  Registro de servidores LSP mediante la **API nueva** `vim.lsp.config()/enable()`.
  Integrado con:
  - `lua/lang/*.lua` (PHP, Bash, Lua, Go, Rust, Python, etc.) para ajustes por lenguaje.
  - Keymaps LSP en `on_attach` (ver `USAGE.md` y `SHORTCUTS.md`).

- **hrsh7th/nvim-cmp** + fuentes:
  - `cmp-nvim-lsp` (LSP)
  - `cmp-buffer` (buffer)
  - `cmp-path` (rutas)
  - `cmp_luasnip` (snippets)
  - **L3MON4D3/LuaSnip** + **rafamadriz//friendly-snippets**
  - **onsails/lspkind.nvim** (iconos en el menú de completado)

  Enter se comporta de forma segura:
  - solo confirma si hay un item  **seleccionado**
  - si no, hace `Enter` normal.

- **hedyhli/outline.nvim**
  (mencionado arriba) como UI de símbolos LSP.

---

## 7. Formateo y lint

- **stevearc/conform.nvim**
  Capa única de formateo por lenguaje.
  - Hook en `BufWritePre` para *format on save* (configurable).
  - `<leader>cf` -> formatear buffer/selección.
  - `:ConformInfo` -> ver formatters disponibles
  - Comandos:
    - `:FormatToggle` -> habilitar/deshabilitar format on save (gloabl).
    - `:FormatToggleBuffer` -> idem pero solo para el buffer actual.

- **mfussenegger/nvim-lint**
  Linting asíncrono disparado en `BufReadPost`, `BufWritePost` e `InsertLeave`.
  - Usa `linters_by_ft` definido en `lua/lang/*.lua`.
  - Comando manual: `:Lint`.

---

## 8. Tests, debug y tareas

- **nvim-neotest/neotest**
  Orquestador de tests multi-lenguaje. Adaptadores:
  - **olimorris/neotest-phpunit** (PHP)
  - **nvim-neotest/neotest-go** (Go)
  - **nvim-neotest/neotest.python** (Python)
  - **rouge8/neotest-rust** (Rust)
  Atajos clave (`lua/plugins/test.lua`):
  - `<leader>tt` -> test más cercano.
  - `<leader>tT` -> tests del fichero.
  - `<leader>ta` -> tests de todo el proyecto.
  - `<leader>ts` -> resumen de tests.
  - `<leader>to` -> output del últmo test.
  - `<leader>tO` -> toggle panel de salida.

- **mfussenegger/nvim-dap**
  Core de debug.
  - **rcarriga/nvim-dap-ui** -> UI de paneles (stacks, watches, etc.).
  - **theHamsta/nvim-dap-virtual-text** -> valores inline.
  - **leoluz/nvim-dap-go** (opcional, Go) -> helpers para Delve.

  Atajos (`lua/plugins/dap.lua`)_
  - `<F5>` -> Iniciar/continur debug.
  - `<F9>` / `<leader>db`-> togle breakpoint.
  - `<leader>dB` -> breakpoint condicional.
  - `<leader>d0`/`<leader>dI`/`<leader>dU`-> step over/into/out.
  - `<leader>du` -> toggle UI DAP
  - `<leader>dq` -> terminar y cerrar.

- **stevearc/overseer.nvim**
  Sistema de tareas (tests, linters, comandos `mise`, etc.)
  - `<leader>ot` -> abrir/cerrar panel de tareas.
  - `<leader>or` -> ejecuta plantilla (p.ej. `phpunit`, `phpstan`, tareas Go/Rust).
  Plantillas por lenguaje en `lua/lang/*.lua`

---

## 9. Git

- **lewis6991/gitsigns.nvim**
  Integración Git por línea: signos, blame, preview, diff.
  Atajos (en bufers con Git):
  - `]c` / `[c` -> siguiente/anterior hunk.
  - `<leader>hs` / `<leader>hr` -> stage/reset hunk.
  - `<leader>hS` / `<leader>hR` -> stage/reset buffer.
  - `<leader>hp` / `<leader>hb` -> preview/blame line.
  - `<leader>hd` / `<leader>hD` -> diff (buffer/contra `~`).

- **kdheepak/lazygit.nvim**
  UI de Git basada en LazyGit.
  - `<leader>gg` -> abre LazyGit en el proyecto actual.

---

## 10. Markdown y documentación

- **iamcco/markdown-preview.nvim**
  Vista de Markdown en navegador.
  - `<leader>mp` -> `MarkdownPreviewToggle`.

- **MeanderingProgrammer/render-markdown.nvim** *(opcional)*
  Render de Markdown dentro de Neovim. Actualmente deshabilitado en `opts`.

---

## 11. Sesiones, terminal y utilidades varias

- **folke/persistence.nvim**
  Manejo de sesiones automáticas por proyecto.
  - `<leader>qs` -> cargar sesión actual.
  - `<leader>ql` -> cargar última sesión.
  - `<leader>qd` -> desactivar guardado de sesión.

- **christoomey/vim-tmux-navigator**
  Navegación entre splits de Neovim y panes de tmux.
  - `<C.h/j/k/l>` y `<C-\>` (pane anterior).

- **stevearc/dressing.nvim**
  Mejora `vim.ui.select`/`vim.ui.input` con popups bonitos (usa Telescope y la UI integrada).

---
