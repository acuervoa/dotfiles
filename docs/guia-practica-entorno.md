# Guía práctica del entorno

Guía progresiva para trabajar sin memorizar cada aplicación por separado. Cada
capa tiene un dueño y tú mantienes el mismo contexto mientras avanzas.

## Modelo mental

| Contexto | Dueño | Qué haces ahí |
|---|---|---|
| i3 | i3 | Workspaces y aplicaciones |
| Kitty | Kitty | Transporte de teclado, terminal y clipboard |
| tmux | tmux | Sesiones, ventanas y panes |
| Bash/ble.sh | Bash/ble.sh | Comandos y edición de línea |
| Neovim | Neovim | Código, LSP y tareas |
| Rofi | Rofi | Selecciones visuales |
| clipmenu | clipmenu | Historial visual del clipboard |
| LazyGit | LazyGit | Revisión Git |
| Polybar/Dunst | Polybar/Dunst | Estado y notificaciones |

`$mod` pertenece a i3, `C-s` es el prefijo de tmux, `<leader>` es Space dentro
de Neovim y `C-r` consulta Atuin en Bash. `p/r/y/n/z` conservan su significado
nativo dentro de Vim; en Bash son comandos contextuales.

## Arranque

La secuencia de inicio es:

```text
i3 $mod+Return → Kitty → tmux
```

tmux usa `C-s` como prefijo: pulsa `C-s` y después la acción.

- `$mod+d`: selector de aplicaciones Rofi.
- `$mod+f`: selector de ventanas Rofi.
- `$mod+v`: historial de clipboard mediante clipmenu/Rofi.
- `$mod+y`: historial de notificaciones de Dunst.
- `C-s ?`: ayuda de tmux.

En los selectores, `Enter` confirma y `Escape` cancela. Kitty transporta las
teclas; tmux decide qué pane o ventana recibe la acción.

## Workflow backend

### Abrir el contexto

Desde Bash:

```bash
tproj nombre-del-proyecto
```

Esto recupera la sesión `proj-nombre-del-proyecto` o crea ventanas de
desarrollo, shell y logs. Para usar la ruta actual o crear un layout completo:

```bash
dev
dev /ruta/al/proyecto
```

El objetivo es conservar un contexto tmux estable, no abrir terminales sueltas.

### Editar y validar

En el pane de Neovim:

1. `<C-p>` o `<leader>ff`: buscar un archivo.
2. `<leader>fg`: buscar texto en el proyecto.
3. `C-h/j/k/l`: mover el foco entre splits y panes.
4. `gd` y `K`: navegar con LSP.
5. `<leader>pt` o `<leader>pT`: ejecutar test cercano o del fichero.
6. `<leader>pf`: formatear; `<leader>pl`: ejecutar lint.
7. `<leader>po`: seleccionar una tarea de Overseer.

`<leader>` significa Space; `<leader>pt` es `Space p t`. Editor, shell y logs
deben continuar en el mismo proyecto.

## Historial, clipboard y selectores

- `C-r` en Bash busca comandos en Atuin.
- FZF filtra y selecciona en wrappers como `proj`, `fo`, `cdf` y `gbr`.
- Rofi gestiona selecciones gráficas de i3.
- clipmenu es el dueño del historial visual; `xsel`, `xclip`, `wl-copy` y
  Kitty son transporte, no gestores de historial.
- `Ctrl+Shift+C` y `Ctrl+Shift+V` copian y pegan en Kitty.
- `cb` copia texto desde Bash usando el backend disponible.

Si no eliges nada, pulsa `Escape`: una selección vacía no debe cambiar de
directorio ni ejecutar acciones.

## Git

Las tres entradas abren el mismo owner visual, LazyGit:

- `lg` desde Bash.
- `C-s g` desde tmux.
- `<leader>gg` desde Neovim.

Usa la entrada del contexto actual. Para cambios pequeños usa Gitsigns (`]c`,
`[c`, `<leader>hp`); para estado, staging e historial abre LazyGit.

## Logs

En el pane shell del proyecto:

```bash
dlogs
```

Selecciona un servicio Docker Compose y sigue sus logs. Usa `lnav` cuando esté
instalado para inspección avanzada. El layout de `dev` puede mantener logs en
un pane dedicado; no uses ese pane para migraciones o despliegues.

## Monitorización

`C-s b` abre btop en un popup de tmux. Polybar muestra el resumen persistente
del escritorio y Dunst informa de eventos sin bloquear el trabajo.

## Cierre y recuperación

- `Escape`: cancelar un selector.
- `<leader>q` en Neovim: cerrar la ventana actual.
- `C-s q` en tmux: confirmar el cierre de un pane.
- `$mod+q` en i3: confirmar el cierre de una ventana/aplicación.
- `C-s ?`: volver a consultar la ayuda.

Si cierras algo por error, `tproj nombre-del-proyecto` recupera el contexto.

## Ejercicios

### Ejercicio 1: editar y validar

**Inicio:** proyecto existente en `~/Workspace`.

1. Ejecuta `tproj nombre-del-proyecto`.
2. Pulsa `<leader>ff` y abre un fichero backend.
3. Edita una línea y guarda con `<leader>w`.
4. Ejecuta `<leader>pt`.
5. Si pasa, ejecuta `<leader>pf`.

**Fin esperado:** permaneces en el mismo proyecto y sesión tmux.

### Ejercicio 2: revisar Git

**Inicio:** proyecto abierto con cambios locales conocidos.

1. Ejecuta `lg` o pulsa `C-s g`.
2. Revisa estado y diff sin confirmar operaciones no deseadas.
3. Sal del popup con la tecla indicada por LazyGit.
4. Vuelve a Neovim con `<leader>gg` sólo si necesitas otra revisión.

**Fin esperado:** conoces los cambios pendientes sin alterar el historial.

### Ejercicio 3: observar y cerrar

**Inicio:** servicios o procesos activos.

1. Ejecuta `dlogs` y selecciona un servicio.
2. Abre btop con `C-s b`.
3. Cancela selectores con `Escape` y cierra el popup de btop.
4. Usa `C-s q` para cerrar sólo un pane temporal y confirma conscientemente.

**Fin esperado:** editor y shell principal permanecen abiertos.

## Fallbacks

| Falta | Alternativa |
|---|---|
| FZF | Comando explícito o `Escape` para cancelar |
| Docker Compose | Revisar logs locales disponibles |
| LazyGit | `git status`, `git diff` y `git log` |
| Yazi | `fo`, `cdf` o `cd` explícito |
| lnav | `less` o stream directo |
| btop | `topme` o `ps` |

## Referencias

- [Atajos globales](../SHORTCUTS.md)
- [Atajos de Neovim](../stow/nvim/.config/nvim/SHORTCUTS.md)
- [Uso de Neovim](../stow/nvim/.config/nvim/USAGE.md)
- [Workflow Neovim](audits/2026-09-01-neovim-workflows.md)
- [Integración de aplicativos](audits/2026-09-02-application-integration.md)
- [Workflows Bash](bash-workflows.md)
- [Memoria muscular Bash](bash-muscle-memory.md)
