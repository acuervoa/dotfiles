
---

## `SHORTCUTS.md`

```markdown
# Atajos globales

Este fichero resume los atajos “de alto nivel” que deben mantenerse coherentes entre Neovim, tmux, i3/WM, terminal, etc.

## Neovim (config/nvim)

### Convenciones

- `<leader>` = espacio (`" "`).
- `<localleader>` = `,`.
- Todos los prefijos de `<leader>` están documentados vía `which-key.nvim`:
  - `<leader>b` → Buffers
  - `<leader>c` → Código / LSP
  - `<leader>d` → Debug
  - `<leader>f` → Files / Find
  - `<leader>g` → Git
  - `<leader>h` → Hunks Git
  - `<leader>m` → Markdown
  - `<leader>o` → Overseer (tareas)
  - `<leader>s` → Search / Switch
  - `<leader>t` → Toggles
  - `<leader>u` → UI
  - `<leader>w` → Write
  - `<leader>x` → Diagnostics / Trouble
  - `<leader>q` → Sesión/quit (persistence, `:q`)

---

### Ventanas y panes

| Acción                         | Modo | Tecla(s)                          |
|--------------------------------|------|-----------------------------------|
| Ir a ventana izquierda/derecha | n    | `<A-h>`, `<A-l>`                  |
| Navegar panes tmux/Neovim      | n    | `<C-h/j/k/l>`, `<C-\>`           |
| VSplit                          | n   | `<leader>%`                       |
| Cerrar ventana                 | n    | `<leader>q`                       |
| Dejar solo esta ventana        | n    | `<leader><BS>`                    |
| Redimensionar vertical         | n    | `<A-S-Left/Right>`, `<C-Left/Right>` |
| Redimensionar horizontal       | n    | `<A-S-Up/Down>`, `<C-Up/Down>`    |

---

### Buffers

| Acción                            | Modo | Tecla(s)       |
|-----------------------------------|------|----------------|
| Listar y saltar a buffer          | n    | `<leader>bb`   |
| Buffer anterior / siguiente       | n    | `<leader>bp/bn`|
| Borrar buffer (seguro)            | n    | `<leader>bd`   |
| Borrar buffer (forzado)           | n    | `<leader>bD`   |
| Cerrar todos salvo actual         | n    | `<leader>bo`   |

---

### Movimiento y edición

| Acción                              | Modo         | Tecla(s)         |
|-------------------------------------|--------------|------------------|
| Mover línea arriba/abajo            | n            | `<A-k>`, `<A-j>` |
| Duplicar línea arriba/abajo         | n            | `<S-A-k>`, `<S-A-j>` |
| Ir a top / bottom de la pantalla    | n            | `gH`, `gL`       |
| Abrir búsqueda (`/`)                | n            | `<C-f>`, `<leader>/` |
| Limpiar highlight de búsqueda       | n            | `<leader><space>`|
| Toggle comentario                   | n/v          | `<C-_>`, `gc`... |

---

### Exploración, búsqueda y símbolos

| Acción                            | Tecla(s)              |
|-----------------------------------|-----------------------|
| Explorer (neo-tree toggle)        | `<C-b>`               |
| Explorer focus                    | `<leader>e`           |
| Buscar archivo (proyecto)         | `<C-p>`, `<leader>ff` |
| Búsqueda texto en proyecto        | `<leader>fg`          |
| Buffers (Telescope)               | `<leader>fb`          |
| Recent files                      | `<leader>fr`          |
| Símbolos del documento            | `<leader>fs`          |
| Historial de notificaciones       | `<leader>fn`, `<leader>uh` |
| Outline de símbolos (LSP)         | `<leader>cs`          |
| TODOs (Trouble/Telescope)         | `<leader>xt`, `<leader>xT` |
| Diagnósticos workspace/buffer     | `<leader>xx`, `<leader>xd` |
| Quickfix / Loclist (Trouble)      | `<leader>xq`, `<leader>xl` |

---

### LSP y código

| Acción                     | Tecla(s)        |
|----------------------------|-----------------|
| Go to definition           | `gd`, `<F12>`   |
| Go to declaration          | `gD`            |
| Go to implementation       | `gi`            |
| Go to type definition      | `gt`            |
| Hover (info)               | `K`             |
| Rename símbolo             | `<F2>`          |
| Code actions               | `<leader>ca`    |
| Diagnósticos buffer (float)| `<leader>cd`    |
| Siguiente/anterior diag    | `[d`, `]d`      |
| Toggle inlay hints         | `<leader>ch`    |

---

### Formato y lint

| Acción                             | Tecla/Comando           |
|------------------------------------|-------------------------|
| Formatear buffer/selección         | `<leader>cf`            |
| Toggle format on save (global)     | `:FormatToggle`         |
| Toggle format on save (buffer)     | `:FormatToggleBuffer`   |
| Ejecutar linter manualmente        | `:Lint`                 |
| Ver info de conform por filetype   | `:ConformInfo`          |

---

### Tests (neotest)

| Acción                         | Tecla(s)       |
|--------------------------------|----------------|
| Test más cercano               | `<leader>tt`   |
| Tests del fichero actual       | `<leader>tT`   |
| Tests de todo el proyecto      | `<leader>ta`   |
| Resumen de tests               | `<leader>ts`   |
| Ver output del último test     | `<leader>to`   |
| Toggle panel de salida         | `<leader>tO`   |

---

### Debug (DAP)

| Acción                          | Tecla(s)        |
|---------------------------------|-----------------|
| Iniciar/continuar debug         | `<F5>`          |
| Toggle breakpoint               | `<F9>`, `<leader>db` |
| Breakpoint condicional          | `<leader>dB`    |
| Step over / into / out          | `<leader>d0/dI/dU` |
| Toggle UI DAP                   | `<leader>du`    |
| Terminar y cerrar debug         | `<leader>dq`    |
| REPL de DAP                     | `<leader>dr`    |
| Repetir último run              | `<leader>dl`    |

---

### Git

| Acción                         | Tecla(s)        |
|--------------------------------|-----------------|
| Siguiente/anterior hunk        | `]c`, `[c`      |
| Stage / reset hunk             | `<leader>hs/hr` |
| Stage / reset buffer           | `<leader>hS/hR` |
| Preview hunk                   | `<leader>hp`    |
| Blame línea                    | `<leader>hb`    |
| Diff buffer / contra `~`       | `<leader>hd/hD` |
| Abrir LazyGit                  | `<leader>gg`    |

---

### Terminal, sesiones y Markdown

| Acción                       | Tecla(s)           |
|------------------------------|--------------------|
| Terminal flotante            | `<C-\`>`           |
| Terminal fallback            | `<leader>\`        |
| Restaurar sesión             | `<leader>qs`       |
| Restaurar última sesión      | `<leader>ql`       |
| Desactivar guardado sesión   | `<leader>qd`       |
| Abrir/Toggle lista de tareas | `<leader>ot`       |
| Ejecutar plantilla Overseer  | `<leader>or`       |
| Preview Markdown (browser)   | `<leader>mp`       |

---

> Para detalles finos (p.ej. qué hace cada tarea de Overseer o qué linters usa cada lenguaje), ver `lua/lang/*.lua` y `PLUGINS.md`.

