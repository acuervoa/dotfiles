# Auditoría de comandos Bash — 2026-08-31

## Alcance y método

Auditoría de la configuración versionada en `stow/bash`, con foco en
ownership, colisiones y paridad entre `.bash_grammar` y el runtime. No se
leyó `~/.bashrc_local`, no se leyó el historial privado y no se modificaron
tmux, i3 ni sus archivos asociados.

El runtime se comprobó en una HOME temporal que contiene los módulos
versionados y un `.bashrc_local` vacío. Para aislar el inventario del coste y
de los efectos de ble.sh/Atuin, se cargaron los módulos mediante
`.bash_lib/bash_lib.sh`; `.bashrc` se comprobó aparte con las integraciones
opcionales neutralizadas. Esto es suficiente para ownership, pero no es una
medición de arranque ni sustituye una prueba con TTY real.

## Resultado ejecutivo

- Catálogo: 134 entradas, sin duplicados y con metadatos válidos.
- Runtime de módulos: 133 entradas resueltas: 42 aliases y 91 funciones.
- `z` es la única entrada condicional no resuelta en el probe aislado: la
  proporciona `zoxide init bash` durante `.bashrc`, no un módulo propio.
- `.bashrc` añade dos comandos públicos fuera del catálogo: `pbcopy` y
  `pbpaste`. Son wrappers intencionados, pero el catálogo no los describe.
- No se observan colisiones silenciosas entre alias y función en el runtime.
- Hay diez colisiones de nombre con binarios externos; todos son nombres
  conocidos y quedan ocultos por alias/función. No cambian el comportamiento
  actual, pero sí aumentan el coste cognitivo.
- Los comandos de una letra quedan identificados: `l`, `n`, `p`, `r`, `y`, `z`.
  `q` no es un comando Bash público.

## Ownership efectivo

| Superficie | Owner versionado | Tipo de ownership |
| --- | --- | --- |
| Alias generales, Git y Docker declarativos | `stow/bash/.bash_aliases` | alias; algunos son condicionales a binarios instalados |
| Git | `stow/bash/.bash_lib/git.sh` | funciones de operación y seguridad |
| Docker/PHP | `stow/bash/.bash_lib/docker.sh` | funciones y wrappers Compose |
| Navegación/clipboard | `stow/bash/.bash_lib/nav.sh` | funciones |
| Runtime, QA y servidores | `stow/bash/.bash_lib/misc.sh` | funciones |
| Sistema, ayuda y reload | `stow/bash/.bash_lib/core.sh` | funciones |
| AI/SimpleBrain | `stow/bash/.bash_lib/ai.sh` | aliases y funciones |
| Readline/ble.sh | `stow/bash/.bash_lib/keymap.sh` | bindings interactivos |
| `pbcopy`/`pbpaste` | `stow/bash/.bashrc` | wrappers gráficos |
| `z` | inicializador externo `zoxide init bash` en `.bashrc` | función dinámica |

`.bash_functions` está vacío. Las filas del catálogo se corresponden con el
owner por grupo y con los marcadores `@cmd` de los módulos; las excepciones
son explícitas en esta tabla.

## Paridad catálogo/runtime

El catálogo pasa `tests/bash_grammar_test.sh`, incluyendo unicidad, grupos,
riesgos, micro-atajos y generación idempotente de `BASH_SHORTCUTS.md`.

| Comprobación | Resultado | Observación |
| --- | --- | --- |
| Entradas catalogadas | 134 | `ai` 16, `git` 33, `docker` 16, `navigation` 17, `php` 12, `runtime` 8, `simplebrain` 10, `system` 8, `utility` 14 |
| Tipos resueltos al cargar módulos | 133 | 42 aliases, 91 funciones |
| Condicionales | `z` | aparece sólo si `zoxide init bash` produce la función |
| Públicos definidos en `.bashrc` pero fuera del catálogo | `pbcopy`, `pbpaste` | gap documental; no se propone cambiarlo en esta fase |
| Micro-atajos | `l n p r y z` | coincide con el contrato existente |

Los aliases `ls`, `ll`, `la`, `cat` y `lg` tienen ramas condicionales en
`.bash_aliases`; en la máquina auditada se activa la rama moderna porque
`eza`, `bat` y `lazygit` están instalados. Esto no es una duplicación runtime:
las ramas son mutuamente excluyentes.

## Colisiones detectadas

### Alias/función y binario externo

`type -P` encontró estos binarios bajo los nombres públicos:

| Nombre | Owner Bash efectivo | Binario oculto |
| --- | --- | --- |
| `cat` | alias | `/usr/bin/cat` |
| `dc` | alias | `/usr/bin/dc` |
| `dcb` | alias | `/usr/bin/dcb` |
| `gc` | alias | `/usr/bin/gc` |
| `grep` | alias | `/usr/bin/grep` |
| `gs` | alias | `/usr/bin/gs` |
| `ls` | alias | `/usr/bin/ls` |
| `trash` | función | `/home/acuervo/.local/bin/trash` |
| `ts` | función | `/usr/bin/ts` |
| `vim` | alias | `/usr/bin/vim` |

El recuento es diez nombres públicos, porque `trash` y `ts` aparecen como
funciones y el resto como aliases. No hay evidencia de una colisión alias ↔
función después de cargar los módulos; la duplicación textual de algunas
asignaciones condicionales queda resuelta por `if/else`.

### Bash frente a Readline, tmux e i3

No hay colisión silenciosa de namespace: son capas distintas. Sí hay
reutilización deliberada de teclas, que debe mantenerse documentada:

| Tecla/nombre | Bash | Readline/ble.sh | tmux | i3 |
| --- | --- | --- | --- | --- |
| `p` | PHP en servicio Compose | — | `display-panes` tras `C-s` | — |
| `r` | editar/ejecutar penúltimo comando | — | split horizontal tras `C-s` | `Mod4+r` entra en resize |
| `n` | Neovim | — | siguiente ventana tras `C-s` | `Mod4+Shift+n` scratch Obsidian |
| `y` | Yazi + `cd` | — | `y` sólo en copy-mode-vi | `Mod4+y` dunst |
| `z` | zoxide | — | zoom tras `C-s` | `Mod4+z` fullscreen |
| `q` | no es comando Bash catalogado | — | cerrar pane con confirmación | `Mod4+q` cerrar ventana con confirmación |
| `C-r` | — | Atuin (`__atuin_history`) | no apropiado por tmux | — |
| `C-t` | — | selector `fo` | sesión nueva de proyecto en tmux | — |
| `M-c` | — | selector `cdf` | — | — |

El prefijo tmux efectivo es `C-s`; `C-s` no es apropiado por el keymap Bash.
Los tests existentes confirman que Readline conserva `C-r`, `C-t`, `M-c`, Tab
y Shift-Tab con owners estables y que no añade `C-s`.

## Clasificación operativa

- **Canónicos:** funciones de `git.sh`, `docker.sh`, `nav.sh`, `misc.sh`,
  `core.sh` y `ai.sh`, además de los aliases públicos documentados en el
  catálogo.
- **Compatibilidad:** `gco`/`gcob`, aliases de listado y los wrappers de
  clipboard; preservan hábitos existentes y no deben renombrarse durante
  esta iteración.
- **Internos:** funciones con prefijo `_`, resolutores de clipboard, helpers
  de Git y keymap. No deben entrar en la gramática pública.
- **Candidatos a memoria muscular:** `l`, `n`, `p`, `r`, `y`, `z`; el catálogo
  los marca con `micro=yes`. Se mantiene exactamente su comportamiento.
- **Candidatos a retirar:** ninguno se retira en esta auditoría. `cat`, `ls`,
  `grep`, `vim`, `dc`, `dcb`, `gc`, `gs`, `trash` y `ts` sólo quedan marcados
  por ocultar binarios externos.

## Riesgos y recomendaciones para la siguiente fase

1. Documentar `pbcopy`, `pbpaste` y la dependencia dinámica de `z` en el
   catálogo o en una sección explícita de runtime, sin cambiar nombres aún.
2. Decidir si los nueve nombres que ocultan binarios requieren una política
   de compatibilidad antes de cualquier renombrado.
3. Medir `.profile`, `.bash_profile`, `.bashrc`, bash-completion, Atuin,
   ble.sh, zoxide, direnv, Starship, mise y fnm con TTY real; el probe de esta
   auditoría no es válido para rendimiento.
4. Mantener tmux e i3 sin cambios: sus bindings no interfieren con el
   namespace Bash, aunque comparten letras en contextos separados.

## Archivos y controles

- Catálogo: `stow/bash/.bash_grammar`
- Entrada Bash: `stow/bash/.bashrc`
- Módulos: `stow/bash/.bash_lib/*.sh`
- Validadores ejecutados: `bash tests/bash_grammar_test.sh` y
  `bash tests/bash_keymap_test.sh`
- No se inspeccionó `~/.bashrc_local`.
