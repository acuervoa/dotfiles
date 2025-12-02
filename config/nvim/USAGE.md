# Guía de uso de la configuración Neovim

## Primer arranque

1. Arranca Neovim con un `NVIM_APPNAME` dedicado (para aislar la config):

   ```bash
   NVIM_APPNAME=nvim nvim
	```

2. En la primera sesión ejecuta los mantenimientos básicos:
	- `:Lazy sync` → instala/actualiza plugins según `lua/plugins` y `lazy-lock.json`.
	- `:Mason` → instala LSPs, DAPs, linters y formatters que vayas a usar.
	- `:CheckHealth` → comprueba dependencias externas (node, php, go, docker, etc.).

3. Revisa los atajos globales en `SHORTCUTS.md` para alinear tmux/i3/kitty y Neovim.

## Atajos esenciales (día a día)

### Ventanas y panes
  - Mover foco entre ventanas de Neovim:
	  - `<Alt-h>` / `<Alt-l>` → ventana izquierda / derecha.
	  - `<C-h/j/k/l>` → se integran con tmux (plugin `vim-tmux-navigator`).
  - Redimensionar splits:
	  - `<A-S-Left/Right>` o `<C-Left/Right>` → ancho.
	  - `<A-S-Up/Down>` o `<C-Up/Down>` → alto.
  - Gestionar ventanas:
	  - `<leader>%i` → `:vsplit`.
	  - `<leader>q`→ cerrar ventana actual.
	  - `<leader><BS>` → `:only` (dejar solo esta ventana).

### Buffers
  - `<leader>bb` → listar buffers y seleccionar (`:ls` + `:b`).
  - `<leader>bp` / `<leader>bn` → buffer anterior/siguiente.
  - `<leader>bd` → borrar buffer actual de forma segura (sin cerrar Neovim).
  - `<leader>bD` → borrar buffer actual forzando (bd!).
  - `<leader>bo` → borrar todos los buffers excepto el actual.

### Movimiento y edición rápida
  - Mover y duplicar líneas:
	  - `<A-j>` / `<A-k>` → mover línea actual arriba/abajo.
	  - `<S-A-j>` / `<S-A-k>` → duplicar línea abajo/arriba.
  - Búsqueda:
	  - `<C-f>` → abre `/` (modo búsqueda).
	  - `<leader>/` → idem (`/`).
	  - `<leader><space>` → limpia el highlight de búsqueda (`:nohlsearch`).
  - Comentarios:
	  - `gc`, `gcc`, `gbc`, etc. → toggles de `Comment.nvim`.
	  - `<C-_>` (normal/visual) → toggle comentario de la selección/línea.
  - Otros:
	  - `gH` / `gL` → saltar al top/bottom visible del buffer.

### Explorador, búsqueda y símbolos
  - Explorador de archivos (neo-tree):
	  - `<C-b>` → toggle panel de archivos.
	  - `<leader>e` → foco en el explorador.
  - Telescope:
	  - `<C-p>` / `<leader>ff` → buscar archivos.
	  - `<leader>fg` → búsqueda global (ripgrep).
	  - `<leader>fb` → buffers abiertos.
	  - `<leader>fr` → archivos recientes.
	  - `<leader>fs` → símbolos del documento actual.
	  - `<leader>fn` → histórico de notificaciones.
  - Symbols Outline:
	  - `<leader>cs` → abrir/cerrar outline de símbolos LSP.
  - TODOs y diagnósticos:
	  - `<leader>xt` → TODOs/FIXME en Trouble.
	  - `<leader>xT` → TODOs en Telescope.
	  - `<leader>xx` / `<leader>xd` → diagnósticos de workspace / buffer.
	  - `<leader>xq` / `<leader>xl` → quickfix / loclist.

### Terminal y sesiones
  - Terminal flotante (`toggleterm`):
	  - `<C-\>` → abrir/cerrar terminal flotante.
	  - `<leader>` → terminal “fallback” (modo normal/terminal).
  - Sesiones (`persistence.nvim`):
	  - `<leader>qs` → restaurar sesión de directorio actual.
	  - `<leader>ql` → última sesión.
	  - `<leader>qd` → marcar que no se guarde sesión para esta carpeta.

---

## LSP, formato y diagnósticos
### LSP (navegación y acciones)

  Atajos definidos en on_attach de lua/plugins/lsp.lua:
  - Navegación:
	  - `gd` / `<F12>` → ir a definición.
	  - `gD` → ir a declaración.
	  - `gi` → ir a implementación.
	  - `gt` → ir a definición de tipo.
  - Información y acciones:
	  - `K` → hover (documentación).
	  - `<F2>` → rename simbólico.
	  - `<leader>ca` → code actions.
	  - `<leader>cd` → ventana flotante con diagnósticos del buffer.
  - Diagnósticos:
	  - `[d` / `]d` → diag anterior/siguiente.
  - Inlay hints:
	  - `<leader>ch` → toggle inlay hints (si el servidor los soporta).

### Completado (`nvim-cmp`)
  - Completado salta en Insert:
	  - `<C-n>` / `<C-p>` → siguiente/anterior item.
	  - `<C-Space>` → forzar menú de completado.
	  - `<C-e>` → cerrar menú.
	  - `<CR>`:
		  - si hay item seleccionado → confirma reemplazando texto.
		  - si **no** hay selección → hace `Enter` normal (no fuerza sugerencias).

### Formato (`conform.nvim`)
  - Formateo manual:
	  - `<leader>cf` → formatear buffer o selección (normal/visual).
  - Format on save:
	  - Se ejecuta en `BufWritePre` si no está desactivado a nivel global/buffer.
	  - `:FormatToggle` → activar/desactivar format on save global.
	  - `:FormatToggleBuffer` → activar/desactivar solo para este buffer.
  - Diagnóstico de configuración:
	  - `:ConformInfo` → ver formatters por tipo de archivo y estado.

### Lint (`nvim-lint`)
  - Se ejecuta automáticamente en:
	  - `BufReadPost`, `BufWritePost`, `InsertLeave`.
  - Comando manual:
	  - `:Lint` → disparar linter del filetype actual.

---

## Tests y depuración
### Tests (neotest)
Atajos en lua/plugins/tests.lua:
	- `<leader>tt` → ejecutar el test más cercano al cursor.
	- `<leader>tT` → ejecutar los tests del fichero actual.
	- `<leader>ta` → tests de todo el proyecto.
	- `<leader>ts` → resumen de tests (panel).
	- `<leader>to` → ver output del último test.
	- `<leader>tO` → abrir/cerrar panel de salida.

Los adaptadores por lenguaje se configuran en `lua/lang/php.lua`, `lua/lang/go.lua`, `lua/lang/python.lua`, `lua/lang/rust.lua`.

### Debug (DAP)
Atajos definidos en `lua/plugins/dap.lua`:
	- Flujo básico:
		- `<F5>` → iniciar/continuar sesión de debug.
		- `<leader>dq` → terminar y cerrar UI.
	- Breakpoints:
		- `<F9> / <leader>db` → toggle breakpoint.
		- `<leader>dB` → breakpoint condicional.
	- Step:
		- `<leader>d0` → step over.
		- `<leader>dI` → step into.
		- `<leader>dU` → step out.
	- Otros:
		- `<leader>du` → abrir/cerrar UI de DAP.
		- `<leader>dr` → abrir REPL de DAP.
		- `<leader>dl` → repetir el último run.

___

## Git y tareas
### Git
  - Gitsigns:
	  - `]c` / `[c` → siguiente/anterior hunk.
	  - `<leader>hs` / `<leader>hr` → stage/reset de hunk.
	  - `<leader>hS` / `<leader>hR` → stage/reset de todo el buffer.
	  - `<leader>hp` → preview del hunk.
	  - `<leader>hb` → blame de la línea.
	  - `<leader>hd` / `<leader>hD` → diff (buffer, buffer vs `~`).
  - LazyGit:
	  - `<leader>gg` → abre `LazyGit` en el directorio actual.

### Tareas (Overseer)
  - `<leader>ot` → Abrir/cerrar lista de tareas (`:OverseerToggle`).
  - `<leader>or` → Ejecutar una plantilla (`:OverseerRun` con `run_template()`).

Las plantillas viven en `lua/lang/*.lua` (PHP, Go, Rust, etc.), y suelen cubrir:
  - Tests (p.ej. `phpunit`, `go test`, `pytest`).
  - Static analysis (`phpstan`, `golangci-lint`, `ruff`, etc.).
  - Tareas `mise run` típicas del proyecto.

___

## Flujos por lenguaje (resumen)
### PHP
  - LSP: `intelephense` (`lua/lang/php.lua`).
  - Formato: `pint` / `php-cs-fixer` vía `conform.nvim`.
  - Lint: `phpstan` vía `nvim-lint`.
  - Tests: `neotest-phpunit` (atajos `<leader>tt/tT/ta`).
  - Tareas extra: `Overseer` → plantillas para `phpunit`, `phpstan`, etc.

### Bash
  - LSP: `bashls`.
  - Formato: `shfmt`.
  - Lint: `shellcheck`.
  - Plantillas para scripts: `new-file-template` + futuro `lua/snippets/bash.lua`.

### Lua
  - LSP: `lua_ls` (config adaptada a Neovim y LuaJIT).
  - Formato: `stylua`.
  - Lint (opcional): `luacheck`.
  - Ideal para desarrollo de tus propios plugins. 

### Go
  - LSP: `gopls` (con `analyses` y `staticcheck`).
  - Formato: `gofumpt` / `goimports` / `gofmt`.
  - Lint: `golangci-lint`.
  - Tests: `neotest-go`.
  - Debug: `nvim-dap-go` (Delve).

### Rust
  - LSP: `rust_analyzer`.
  - Formato: `rustfmt`.
  - Lint: `clippy` (configurado en `lang/rust.lua`).
  - Tests: `neotest-rust`.

### Python
  - LSP: `pyright`.
  - Formato y lint: `ruff` (`ruff_fix`, `ruff_format`, `ruff_organize_imports`).
  - Tests: `neotest-python` (`pytest`).

---

## Mantenimiento y troubleshooting
- **Plugins**
	- `:Lazy sync` → sincronizar con el repo (añadir/actualizar).
	- `:Lazy clean` → eliminar plugins huérfanos.
	- `:Lazy restore` → restaurar exactamente lo registrado en `lazy-lock.json`.
- **LSP/DAP/linters**
	- `:Mason` → instalar/eliminar/actualizar servidores y herramientas externas.
- **Salud del entorno**
	- `:CheckHealth` → comprobar binarios y módulos de Neovim.
- **Lock de plugins**
	-Si `lazy-lock.json` se corrompe, puedes borrarlo y ejecutar:
		- `:Lazy restore` o `:Lazy sync` para regenerarlo.
- **Errores de plugins**
	- `:messages` → log básico.
	- Directorio de estado de lazy: usualmente `~/.local/state/nvim/lazy`.

Para cualquier atajo concreto, consulta también `SHORTCUTS.md`.
