# Diseño: Neovim como editor general con foco backend

## Objetivo

Convertir la configuración actual de Neovim en un editor general predecible,
rápido y mantenible, optimizado especialmente para desarrollo backend sin
romper los atajos, comandos ni workflows existentes.

La primera iteración prioriza auditoría, consolidación y validación. No se
añadirán plugins por defecto ni se eliminarán plugins activos sin evidencia de
duplicidad, coste o fallo.

## Invariantes

- Se conserva `mapleader = " "` y `maplocalleader = ","`.
- Se conservan los mappings existentes salvo duplicidad o error demostrado.
- Se conserva la integración tmux con `C-h/j/k/l` y el prefijo tmux `C-s`.
- No se modifica `.bashrc_local`, `.tmux.conf` ni la configuración de i3.
- `lazy-lock.json` se modifica solo si una actualización validada lo exige.
- La configuración debe cargar sin red y degradar con mensajes claros cuando
  falten herramientas opcionales.

## Arquitectura objetivo

### Núcleo

`init.lua`, `config/options.lua`, `config/autocmds.lua`, `config/keymaps.lua`
y `config/lazy.lua` contienen solo comportamiento transversal: opciones,
autocmds, mappings globales, bootstrap de lazy y carga de módulos.

### Capacidades

Los plugins se agrupan por capacidad, manteniendo los archivos existentes como
owners cuando ya sean claros:

- navegación y búsqueda: Telescope, Neo-tree, bufferline y navegación de
  buffers;
- edición: blink, LuaSnip, autopairs, surround, comentarios y sleuth;
- código: LSP, Mason, Treesitter, formato y lint;
- ejecución: tests, DAP, Overseer y terminales;
- colaboración: Git, tmux-navigator y Codex;
- interfaz: tema, statusline, diagnóstico, breadcrumbs y notificaciones.

Se eliminarán definiciones duplicadas, especialmente la especificación de
`Comment.nvim` y la integración `nvim-ts-context-commentstring`, dejando un
único owner por plugin.

### Lenguajes

Los módulos `lua/lang/*.lua` siguen siendo la fuente de configuración por
lenguaje. Backend tendrá el camino más completo para PHP/Laravel, Docker,
tests, lint, formato y Xdebug; Bash, Lua, Go, Python y Rust conservarán sus
configuraciones existentes como perfiles de primera clase.

## Workflows objetivo

1. **General:** abrir proyecto, encontrar archivos, buscar texto, cambiar
   buffers, navegar símbolos, editar, formatear, revisar diagnósticos y salir
   sin estado perdido.
2. **Backend:** detectar raíz, abrir Docker/Laravel, navegar rutas/clases,
   ejecutar test cercano o suite, revisar lint/formato y depurar con Xdebug.
3. **Git:** revisar cambios, consultar hunks, navegar histórico, abrir
   conflictos y usar el flujo seguro de Git sin duplicar lógica de Bash.
4. **AI:** explicar archivo/repositorio, revisar diff, aplicar cambios solo
   mediante los comandos Codex existentes y conservar el control del usuario.
5. **Terminal/tmux:** abrir terminal auxiliar, moverse entre panes y volver a
   Neovim sin conflicto con `C-s`.

## Fases de implementación

### Fase A — baseline automatizado

- Ejecutar carga headless con HOME/XDG aislados.
- Capturar `:checkhealth`, tiempo de arranque, plugins cargados y errores de
  `vim.notify`/`vim.log`.
- Extraer mappings y comandos definidos por cada módulo.
- Validar `lazy-lock.json`, versiones y ausencia de cambios externos.

### Fase B — consolidación de ownership

- Unificar specs duplicadas de Comment y Treesitter commentstring.
- Revisar keymaps repetidos, grupos which-key y mappings de plugins.
- Mantener aliases o mappings de compatibilidad si hay más de una ruta válida.
- Actualizar documentación solo desde el estado validado.

### Fase C — backend y perfiles generales

- Verificar PHP/Laravel, Docker, tests, DAP/Xdebug, formato y lint.
- Verificar que los demás lenguajes no pierden soporte.
- Añadir fallbacks solo donde la configuración actual falle de forma observable.

### Fase D — rendimiento y release

- Medir antes/después por evento de carga.
- Lazy-load solo plugins cuyo coste esté demostrado y cuya capacidad conserve
  el mismo mapping/comando.
- Ejecutar tests Lua/headless, healthchecks y validación de integración.
- Commit, tag y release independientes para los cambios de Neovim.

## Validación

- `nvim --headless '+qa'` con la configuración instalada.
- Carga con HOME/XDG temporal y sin red.
- `nvim --headless '+checkhealth' '+qa'` y carga de `config.options`.
- Tests de `codex/init_spec.lua` y cualquier test Lua adicional.
- Comprobación de mappings críticos: leader, navegación tmux, buffers,
  búsqueda, formato, tests, DAP y Codex.
- `git diff --check`, ShellCheck de scripts y escaneo de secretos.
- Confirmación de que no cambian `.bashrc_local`, `.tmux.conf` ni i3.
- Prueba de ausencia de dependencias opcionales cuando sea automatizable.

## Fuera de alcance inicial

- Cambiar el prefijo tmux o la gramática i3.
- Sustituir Telescope, Neo-tree, blink, LSP, DAP o el sistema de tests sin
  baseline comparativo.
- Activar sincronización automática de plugins o actualizar todo el lockfile
  por rutina.
- Rediseñar visualmente el tema Catppuccin.
- Retirar soporte de cualquier lenguaje existente.

## Criterio de salida

La fase se considera completada cuando existe un único owner por capacidad y
plugin, la configuración arranca sin errores en entorno aislado, los mappings
críticos son estables, el workflow backend está validado, los lenguajes
generales siguen operativos y cualquier mejora de rendimiento tiene medición
antes/después.
