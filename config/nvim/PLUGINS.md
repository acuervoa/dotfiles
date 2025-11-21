# Neovim config (VSCode-like)

Configuración de Neovim orientada a desarrollo diario (PHP, JS/TS, etc.) con experiencia tipo VSCode: LSP, autocompletado, tests, debug, tareas y navegación rápida.

- Neovim mínimo: 0.11+
- `runtime` principal: `~/.config/nvim`
- `<leader>` = **espacio**

---

## Convenciones de teclado

- `<leader>` → barra espaciadora.
- Prefijos principales (según `which-key`):
  - `<leader>b` → buffers
  - `<leader>c` → código / LSP
  - `<leader>d` → debug
  - `<leader>f` → ficheros / búsqueda
  - `<leader>g` → Git
  - `<leader>h` → hunks (GitSigns)
  - `<leader>o` → Overseer (tareas)
  - `<leader>t` → toggles / tests
  - `<leader>u` → UI (notificaciones, etc.)
  - `<leader>w` → escribir / guardar
  - `<leader>x` → diagnósticos / Trouble

---

## 1. Core / framework de plugins

### `folke/which-key.nvim`

Muestra un menú de ayuda de atajos al pulsar `<leader>` y otros prefijos.

- Ejemplo: pulsa `<leader>` y espera un momento → aparece una ventana con todos los grupos (`b`, `f`, `g`, etc.).

### `nvim-lua/plenary.nvim`

Librería de utilidades Lua usada por Telescope, Neo-tree, LazyGit, todo-comments, etc.

- Ejemplo: no se usa directamente; si desinstalas `plenary`, varios plugins dejarían de funcionar.

### `MunifTanjim/nui.nvim`

Toolkit de UI para ventanas flotantes, menús, etc. Lo usa sobre todo Neo-tree.

- Ejemplo: la ventana lateral de Neo-tree se construye con `nui` (no hay comando directo).

### `nvim-tree/nvim-web-devicons` + `nvim-mini/mini.icons`

Iconos para ficheros y tipos de LSP.

- Ejemplo: abre Neo-tree o el bufferline y verás iconos distintos para `.php`, `.js`, `.md`, etc.

---

## 2. Apariencia y UI

### `Mofiqul/vscode.nvim`

Tema de colores principal tipo VSCode.

- Ejemplo: `:colorscheme vscode` para volver al tema si cambias a otro.

### `akinsho/bufferline.nvim`

Barra de pestañas de buffers en la parte superior con integración de diagnósticos.

- Ejemplo: `:BufferLineCycleNext` para ir al siguiente buffer en la barra.

### `nvim-lualine/lualine.nvim`

Statusline global (modo, rama, diffs, diagnósticos, LSP, encoding, etc.).

- Ejemplo: mira la barra inferior; cuando conectas un LSP verás los nombres de los clientes (p.ej. `intelephense`) en la sección central/derecha.

### `lukas-reineke/indent-blankline.nvim`

Muestra guías verticales de indentación.

- Ejemplo: abre un fichero con bloques anidados → verás líneas `│` marcando cada nivel de indent.

### `karb94/neoscroll.nvim`

Scroll suave para los movimientos estándar.

- Ejemplo: usa `<C-d>` / `<C-u>` en un fichero largo → el scroll se anima suavemente en lugar de “saltar”.

### `rcarriga/nvim-notify`

Sistema de notificaciones más cómodo que `:echo`.

- Ejemplo: tras varios mensajes, usa `<leader>un` para limpiar todas las notificaciones pendientes.

### `stevearc/dressing.nvim`

Mejora las ventanas de entrada/selección (`vim.ui.input` y `vim.ui.select`).

- Ejemplo: ejecuta `:lua vim.lsp.buf.code_action()` → el listado de acciones aparece en una ventana flotante “bonita” (vía Telescope o builtin).

### `utilyre/barbecue.nvim` + `SmiteshP/nvim-navic`

Breadcrumbs de símbolos (tipo ruta: módulo → clase → método) encima de la ventana.

- Ejemplo: abre un fichero PHP con clases/métodos → verás la ruta actual en la parte superior de la ventana (barbecue usa `nvim-navic` como fuente LSP).

---

## 3. Terminal integrado

### `akinsho/toggleterm.nvim`

Terminal flotante integrado en Neovim.

- Ejemplo 1: pulsa `<C-\`>` para abrir/cerrar un terminal flotante.
- Ejemplo 2: `<leader>\`` hace de “fallback” para `:ToggleTerm` en modo normal/terminal.

---

## 4. Explorador, búsqueda y símbolos

### `nvim-neo-tree/neo-tree.nvim`

Explorador de ficheros lateral.

- Ejemplo:
  - `<C-b>` → abre/cierra el árbol a la izquierda.
  - `<leader>e` → mueve el foco al panel de Neo-tree.

### `nvim-telescope/telescope.nvim`

Buscador difuso para ficheros, texto, buffers, comandos, símbolos, etc.

- Ejemplos:
  - `<C-p>` o `<leader>ff` → `find_files` (buscar archivo en el proyecto).
  - `<leader>fg` → `live_grep` (buscar texto en todo el árbol).
  - `<leader>fb` → lista de buffers abiertos.
  - `<leader>fs` → símbolos del documento vía LSP.

### `nvim-telescope/telescope-fzf-native.nvim`

Extensión de Telescope que usa FZF como motor más rápido.

- Ejemplo: ninguna acción extra; simplemente acelera y mejora el ranking de las búsquedas de Telescope.

### `nvim-telescope/telescope-ui-select.nvim`

Reemplaza los menús de selección estándar por Telescope.

- Ejemplo: ejecuta `:lua vim.lsp.buf.code_action()` → las acciones se muestran en un popup de Telescope en vez de una lista simple.

### `hedyhli/outline.nvim`

Panel lateral de símbolos (Outline) similar al de VSCode.

- Ejemplo: `<leader>cs` → abre `:Outline` a la derecha con funciones, clases, etc., del fichero actual.

---

## 5. Movimiento y edición

### `folke/flash.nvim`

Saltos rápidos a texto usando resaltado inteligente.

- Ejemplos:
  - Pulsa `f` en modo normal y escribe unas letras → saltas rápido a esa posición.
  - Pulsa `F` → salto basado en árbol sintáctico (Treesitter) hacia bloques/símbolos.

### `numToStr/Comment.nvim`

Comentar/descomentar líneas y bloques.

- Ejemplos:
  - `<C-/>` (`<C-_>`) en modo normal → comenta/descomenta la línea actual.
  - Selecciona varias líneas en visual y pulsa `<C-/>` → comenta/descomenta el bloque.

### `windwp/nvim-autopairs`

Inserta automáticamente cierres de paréntesis, llaves y comillas.

- Ejemplo: escribe `(` en Insert → se inserta automáticamente `)` y el cursor queda en medio.

### `kylechui/nvim-surround`

Gestión de “envolturas” (comillas, paréntesis, etc.).

- Ejemplos:
  - `ysiw)` → rodea la palabra bajo el cursor con `(...)`.
  - `cs"'` → cambia envoltura de `"` a `'` alrededor del texto actual.

### `folke/todo-comments.nvim`

Resalta `TODO`, `FIXME`, `BUG`, etc., y permite listarlos.

- Ejemplos:
  - Escribe `// TODO: revisar esta función` → se resalta en color específico.
  - `<leader>xT` → `:TodoTelescope` (lista todos los TODO/FIXME en el proyecto).
  - `<leader>xt` → abre los TODOs en una vista tipo Trouble.

---

## 6. LSP, completado y snippets

### `mason-org/mason.nvim`

Gestor de binarios (LSP, formatters, linters, DAP).

- Ejemplo: `:Mason` → abre UI para instalar/actualizar servidores como `intelephense`, `lua_ls`, etc.

### `mason-org/mason-lspconfig.nvim`

Integra Mason con `nvim-lspconfig` para configurar servidores LSP automáticamente.

- Ejemplo: se encarga de que `intelephense` o `tsserver` se registren y arranquen sin config manual por cada uno (no hay comando extra).

### `neovim/nvim-lspconfig`

Configuración de LSP y mapeos de código.

- Ejemplos:
  - `gd` o `<F12>` → ir a definición.
  - `gr` → referencias.
  - `<leader>cr` → renombrar símbolo.
  - `<leader>ca` → acciones de código (code actions).
  - `<leader>cd` → mostrar diagnósticos LSP en un popup en la línea actual.

### `hrsh7th/nvim-cmp`

Motor de autocompletado.

- Ejemplos:
  - En Insert, pulsa `<C-Space>` para abrir el menú de completado manualmente.
  - Usa `<Tab>` / `<S-Tab>` para moverte por las sugerencias.
  - `<CR>` acepta la sugerencia seleccionada.

### `hrsh7th/cmp-nvim-lsp`

Fuente de completado de LSP para `nvim-cmp`.

- Ejemplo: cuando escribes el nombre de una función/método de la API de PHP/TS, las sugerencias vienen del LSP (marcadas con `[LSP]` en el menú).

### `hrsh7th/cmp-buffer`

Propone palabras ya presentes en el buffer actual como completado.

- Ejemplo: escribe las primeras letras de un identificador largo ya usado en el fichero → aparecerá como sugerencia `[Buffer]`.

### `hrsh7th/cmp-path`

Completado de rutas de ficheros.

- Ejemplo: escribe `./` o `/` en un string o comando → `nvim-cmp` sugiere rutas `[Path]`.

### `L3MON4D3/LuaSnip`

Motor de snippets.

- Ejemplo: cuando `nvim-cmp` ofrece una entrada con icono de snippet (`[Snippet]`), al aceptarla se expande el snippet y puedes saltar entre “huecos” con `<Tab>` / `<S-Tab>`.

### `saadparwaiz1/cmp_luasnip`

Conecta `LuaSnip` con `nvim-cmp`.

- Ejemplo: los snippets definidos en `LuaSnip` y `friendly-snippets` aparecen como sugerencias de tipo `[Snippet]` en el menú de `nvim-cmp`.

### `rafamadriz/friendly-snippets`

Colección de snippets predefinidos para muchos lenguajes.

- Ejemplo: en ficheros JavaScript/TypeScript/PHP verás snippet suggestions habituales (funciones, estructuras, etc.) sin definir nada a mano.

### `onsails/lspkind.nvim`

Añade iconos y anotaciones tipo VSCode al menú de completado.

- Ejemplo: en el menú de `nvim-cmp` ves iconos distintos para funciones, variables, clases, snippets, y etiquetas `[LSP]`, `[Buffer]`, etc.

---

## 7. Treesitter y textobjects

### `nvim-treesitter/nvim-treesitter`

Highlight, indentación y selección basada en árbol sintáctico.

- Ejemplos:
  - Usa `<leader><CR>` varias veces para expandir la selección (de símbolo → expresión → función → archivo).
  - Usa `<BS>` (Backspace) para reducir la selección.

### `nvim-treesitter/nvim-treesitter-textobjects`

Textobjects semánticos (funciones, clases, etc.).

- Ejemplos:
  - `vaf` / `vif` → seleccionar toda la función o solo su cuerpo.
  - `vac` / `vic` → seleccionar toda la clase o su interior.
  - `[f` / `]f` → saltar a la función anterior/siguiente.

---

## 8. Formateo y lint

### `stevearc/conform.nvim`

Framework de formateo por fichero.

- Ejemplos:
  - `<leader>cf` → formatea el buffer o selección (`php-cs-fixer`/`pint` para PHP, `prettier(d)` para JS/TS/JSON/etc., `stylua` para Lua, etc.).
  - Se ejecuta automáticamente en `BufWritePre` para ciertos lenguajes (según tu configuración).

### `mfussenegger/nvim-lint`

Lanzador asíncrono de linters.

- Ejemplo: guarda un fichero PHP (`phpstan`) o JS/TS (`eslint_d`) → verás diagnósticos adicionales (warning/error) aparecer como diagnósticos de Neovim.

---

## 9. Git

### `lewis6991/gitsigns.nvim`

Signs de Git en el margen y acciones sobre “hunks”.

- Ejemplos:
  - `[c` / `]c` → ir al hunk previo/siguiente.
  - `<leader>hs` → stage del hunk actual.
  - `<leader>hr` → reset del hunk actual.
  - `<leader>hd` → diff del fichero actual.

### `kdheepak/lazygit.nvim`

Integra LazyGit dentro de Neovim.

- Ejemplo: `<leader>gg` → abre LazyGit en una ventana flotante dentro de Neovim.

---

## 10. Tests

### `nvim-neotest/neotest`

Framework para lanzar tests desde Neovim con UI unificada.

- Ejemplos:
  - `<leader>tt` → ejecuta el test más cercano al cursor.
  - `<leader>tT` → ejecuta todos los tests del fichero actual.
  - `<leader>ts` → abre/cierra el panel de resumen de tests.
  - `<leader>to` → abre el output detallado del último test.

### `olimorris/neotest-phpunit`

Adaptador de `neotest` para PHPUnit (PHP).

- Ejemplo: cuando estás en un fichero de tests PHP y usas `<leader>tt`, internamente se ejecuta `phpunit` vía Docker/`docker compose` según tu plantilla (no hay comando extra).

### `antoinemadec/FixCursorHold.nvim`

Arreglo para el evento `CursorHold` que usan plugins como `neotest`.

- Ejemplo: evita problemas de refresco/parpadeo y hace que eventos como el hover o paneles de tests se actualicen correctamente (no lo usas directamente).

---

## 11. Debug (DAP)

### `mfussenegger/nvim-dap`

Core del debug adapter protocol (breakpoints, step, etc.).

- Ejemplos:
  - `<F5>` → start/continue debug.
  - `<leader>d0` → step over.
  - `<leader>dI` / `<leader>dU` → step into / step out.
  - `<leader>db` → toggle breakpoint.
  - `<leader>dB` → breakpoint condicional (pide condición).

### `rcarriga/nvim-dap-ui`

UI para `nvim-dap` (paneles de variables, breakpoints, etc.).

- Ejemplos:
  - `<leader>du` → abrir/cerrar la UI de debug (scopes, breakpoints, pilas…).
  - Se abre automáticamente al arrancar una sesión DAP.

### `theHamsta/nvim-dap-virtual-text`

Muestra valores de variables inline mientras depuras.

- Ejemplo: en una sesión de debug con Xdebug, verás el valor de variables directamente al lado de las líneas de código relevantes.

### `nvim-neotest/nvim-nio`

Infraestructura asíncrona para `nvim-dap-ui` y `neotest`.

- Ejemplo: no se usa directamente; permite que las UIs de debug/tests sean reactivas sin bloquear Neovim.

---

## 12. Sesiones, tareas y tmux

### `stevearc/overseer.nvim`

Gestor de tareas reproducibles (build, test, QA, etc.).

- Ejemplos:
  - `<leader>ot` → abre/cierra la lista de tareas.
  - `<leader>or` → ejecuta una plantilla (p.ej. “PHP: PHPUnit nearest test”, “mise: run qa”, etc.) definida en tu `tasks.lua`.

### `folke/persistence.nvim`

Gestión automática de sesiones (buffers, ventanas, etc.).

- Ejemplos:
  - `<leader>qs` → restaurar la sesión actual.
  - `<leader>ql` → cargar la última sesión usada.
  - `<leader>qd` → desactivar guardado de sesión para la sesión actual.

### `christoomey/vim-tmux-navigator`

Navegación fluida entre splits de Neovim y panes de tmux.

- Ejemplos:
  - `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` → moverte entre ventanas/panes sin pensar si estás en tmux o en Neovim.
  - `<C-\>` → saltar al último pane visitado.

---

## 13. Resumen rápido

- **Tema y UI**: `vscode.nvim`, `bufferline.nvim`, `lualine.nvim`, `indent-blankline.nvim`, `neoscroll.nvim`, `nvim-notify`, `dressing.nvim`, `barbecue.nvim` + `nvim-navic`, `toggleterm.nvim`.
- **Exploración / búsqueda**: `neo-tree.nvim`, `telescope.nvim` (+ `telescope-fzf-native`, `telescope-ui-select`), `outline.nvim`.
- **Edición / movimiento**: `flash.nvim`, `Comment.nvim`, `nvim-autopairs`, `nvim-surround`, `todo-comments.nvim`.
- **LSP, completado, snippets**: `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`, `nvim-cmp` + fuentes (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip`), `LuaSnip`, `friendly-snippets`, `lspkind.nvim`.
- **Árbol sintáctico**: `nvim-treesitter` + `nvim-treesitter-textobjects`.
- **Formateo / lint**: `conform.nvim`, `nvim-lint`.
- **Git**: `gitsigns.nvim`, `lazygit.nvim`.
- **Tests**: `neotest`, `neotest-phpunit`, `FixCursorHold.nvim`.
- **Debug**: `nvim-dap`, `nvim-dap-ui`, `nvim-dap-virtual-text`, `nvim-nio`.
- **Sesiones / tareas / tmux**: `overseer.nvim`, `persistence.nvim`, `vim-tmux-navigator`.
- **Infra**: `plenary.nvim`, `nui.nvim`, `web-devicons`, `mini.icons`.

---
