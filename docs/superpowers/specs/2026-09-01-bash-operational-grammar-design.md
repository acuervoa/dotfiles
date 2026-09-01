# Diseño: gramática operativa Bash por contexto

Fecha: 2026-09-01  
Estado: aprobado para revisión escrita  
Alcance: documentación y especificación; sin cambios de comportamiento

## Objetivo

Convertir la auditoría de comandos Bash y la línea base de rendimiento en una
gramática operativa clara para el uso diario. La gramática debe cubrir Bash,
tmux e i3 como capas relacionadas, conservar compatibilidad estricta y
priorizar secuencias cortas y repetibles sobre la cantidad de atajos.

## Decisiones de diseño

### Contexto como estructura principal

La documentación se organiza por contexto de uso:

- **i3:** aplicaciones, enfoque, movimiento, workspaces y modos de ventana.
- **tmux:** panes, ventanas y sesiones después del prefijo `C-s`.
- **Bash:** acciones sobre proyectos, Git, Docker/PHP, runtime y AI.
- **Readline/ble.sh:** edición de línea, historial y selectores interactivos.

Cada capa conserva ownership exclusivo sobre sus bindings. Una misma letra
puede repetirse si pertenece a contextos diferentes; la documentación debe
mostrar el contexto completo para evitar interpretarlo como una colisión.

### Prefijos como índice rápido

Dentro de Bash, las familias se indexan por prefijo:

| Familia | Dominio |
| --- | --- |
| `g*` | Git |
| `d*` | Docker |
| `p*` | PHP/Laravel |
| `r*` | runtime, QA y servidores |
| `af*` | AI Flow |
| `sb*` | SimpleBrain |
| sin prefijo | navegación, sistema, utilidades y memoria muscular |

Los prefijos son una ayuda de descubrimiento, no una autorización para
renombrar comandos existentes ni para introducir aliases nuevos.

### Riesgo como señal

La documentación conservará los niveles del catálogo:

- `safe`: lectura o consulta sin mutación prevista;
- `confirm`: requiere confirmación explícita;
- `mutating`: modifica estado, archivos, procesos, staging, sesiones o
  servicios.

Los comandos peligrosos se documentan junto con su precondición y resultado
de validación. No se cambiarán sus barreras en esta fase.

## Ownership

| Superficie | Owner |
| --- | --- |
| Alias públicos | `stow/bash/.bash_aliases` |
| Git | `stow/bash/.bash_lib/git.sh` |
| Docker y PHP | `stow/bash/.bash_lib/docker.sh` |
| Navegación y clipboard | `stow/bash/.bash_lib/nav.sh` |
| Runtime, QA y servidores | `stow/bash/.bash_lib/misc.sh` |
| Sistema y ayuda | `stow/bash/.bash_lib/core.sh` |
| AI y SimpleBrain | `stow/bash/.bash_lib/ai.sh` |
| Readline y ble.sh | `stow/bash/.bash_lib/keymap.sh` |
| Wrappers `pbcopy`/`pbpaste` | `stow/bash/.bashrc` |
| Función `z` | `zoxide init bash`, invocado por `.bashrc` |

Las funciones internas con prefijo `_` no forman parte de la gramática
pública. `.bash_functions` sigue siendo un punto de compatibilidad vacío.

## Workflows

Todos los workflows siguen el patrón `entrar → inspeccionar → actuar →
validar → cerrar`.

### Backend PHP

`proj` o `tproj` → `gs` → `dcu`/`dev` → `p`/`part`/`ptest` → `qa`.

### Servidores

`ports` → `rserve` → `dlogs`/`topme` → `rqa` o `rtest`.

### Git

`gs` → `gd`/`gds` → `ga` → `gcm` o `wip` → `gp`.

`gclean`, `gundo` y `gpf` se mantienen como operaciones de confirmación
explícita; `gpf` conserva `--force-with-lease`.

### Docker

`docps`/`dps` → `dlogs`/`dsh` → `dcu`/`dcud` → `dcrb`/`dorebuild` con
confirmación → `dclean`.

### AI

`sbs` o `af` → `afl` cuando se lanza un agente → `sbsb`/`sbo` para consultar
estado → `sbe`/`afx` para cerrar → `aflastdraft`/`afapplylast` para revisar o
aplicar una destilación.

## Memoria muscular y compatibilidad

Los micro-atajos actuales son `l`, `n`, `p`, `r`, `y` y `z`. Se documentan
como atajos contextuales, manteniendo exactamente su comportamiento.

Los aliases y wrappers existentes se conservan como compatibilidad durante
esta fase. No se retira ni renombra ningún comando. Las colisiones conocidas
con binarios externos, la función dinámica `z` y `pbcopy`/`pbpaste` fuera del
catálogo se mantienen como riesgos documentales.

## Artefactos documentales

La implementación posterior podrá crear o actualizar:

1. una guía de workflows Bash separada del catálogo generado;
2. una matriz de teclas compartidas Bash–tmux–i3;
3. ejercicios de memoria muscular por workflow;
4. referencias al catálogo y a `BASH_SHORTCUTS.md`.

Los artefactos no deben duplicar definiciones ni presentar bindings no
observados en los archivos efectivos.

## Validación

La validación documental y estática exigirá:

- cada entrada del catálogo aparece en un workflow o queda marcada como
  auxiliar;
- ownership trazable a un archivo versionado;
- ningún nombre nuevo, renombrado o retirado;
- `.bashrc_local` no se modifica;
- tmux e i3 no se modifican;
- el generador de `BASH_SHORTCUTS.md` permanece idempotente;
- los tests Bash, las comprobaciones de sintaxis y `git diff --check` pasan.

La siguiente fase no aplicará carga diferida ni cambios de bindings. Cualquier
optimización de rendimiento requiere primero la medición Kitty + i3 + tmux
descrita en el baseline de 2026-09-01.
