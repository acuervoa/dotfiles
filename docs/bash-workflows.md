# Workflows Bash por contexto

Guía operativa breve para combinar los atajos existentes sin cambiar sus
nombres ni su comportamiento. La regla general es: entrar, inspeccionar,
actuar, validar y cerrar.

## Regla de lectura

Índice de familias:

| Prefijo | Dominio |
| --- | --- |
| `g*` | Git |
| `d*` | Docker |
| `p*` | PHP/Laravel |
| `r*` | runtime/QA/servers |
| `af*` | AI Flow |
| `sb*` | SimpleBrain |
| `l`, `n`, `p`, `r`, `y`, `z` | microcomandos |
| Otros comandos sin prefijo | navegación, sistema y utilidades |

Cuando ya estás dentro del proyecto, inspecciona `gs` o `docps` antes de
mutar; `proj`/`tproj` son comandos de entrada o sesión. Los selectores se
pueden cancelar con `Esc` o con la opción de cancelar que muestre el selector.
Ante una confirmación, recházala para salir sin cambios. Después de mutar,
valida con `rtest`, `qa` o `rqa`.

## Backend PHP

Secuencia principal: `proj/tproj → gs → dcu/dev → p/part/ptest → qa`.

| Propósito | Alcance de mutación | Validación |
| --- | --- | --- |
| Entrar al proyecto, revisar el estado, levantar desarrollo, ejecutar PHP/Artisan o tests y comprobar calidad. | `proj`/`tproj` cambia el directorio o la sesión; `dcu`/`dev` arranca servicios; `p`/`part` puede modificar datos o archivos según el subcomando; `ptest` es de lectura operativa. | Confirmar que `gs` está limpio o entendido; terminar con `qa` y, cuando aplique, `ptest`. |

`pmig`, `pseed` y `pclear` son confirmation-sensitive: revisa el proyecto y
rechaza la confirmación si el alcance no es el esperado.

## Servidores

Secuencia de observación y servicio: `ports → rserve → dlogs/topme → rqa/rtest`.

| Propósito | Alcance de mutación | Validación |
| --- | --- | --- |
| Ver puertos, arrancar el servidor, observar logs o procesos y ejecutar QA/tests. | `ports`, `dlogs`, `topme`, `rqa` y `rtest` son consultas o validaciones; `rserve` arranca un servidor y altera el estado de ejecución. | Comprobar puertos y procesos con `ports`/`topme`, revisar `dlogs` y cerrar con `rqa` o `rtest`. |

## Git

Secuencia de entrega: `gs → gd/gds → ga → gcm/wip → gp`.

| Propósito | Alcance de mutación | Validación |
| --- | --- | --- |
| Revisar el estado y las diferencias, preparar cambios, crear un commit y publicarlo. | `gs`, `gd` y `gds` leen; `ga` modifica staging; `gcm`/`wip` crean commits; `gp` publica en el remoto. | Inspeccionar `gs` antes de `ga`, revisar `gds` antes del commit y ejecutar `qa`, `rqa` o `rtest` antes de `gp`. |

`gclean`, `gundo`, `gpf` y `gp` son confirmation-sensitive. Rechaza la
confirmación si las ramas, el commit o el remoto no coinciden con lo
previsto. `gpf` conserva el push forzado protegido con lease.

## Docker

Secuencia de inspección y operación: `docps/dps → dlogs/dsh → dcu/dcud → dcrb/dorebuild → dclean`.

| Propósito | Alcance de mutación | Validación |
| --- | --- | --- |
| Inspeccionar contenedores, consultar logs o entrar en un servicio, arrancar Compose, reconstruir y limpiar recursos. | `docps`, `dps` y `dlogs` leen; `dsh` abre una shell; `dcu`/`dcud` arrancan servicios; `dcrb`/`dorebuild` reconstruyen; `dclean` elimina recursos no usados. | Inspeccionar `docps` antes de mutar, revisar `dlogs` después y ejecutar `rtest`, `qa` o `rqa`. |

`dclean`, `dcrb` y `dorebuild` son confirmation-sensitive. Rechaza la
confirmación si no puedes identificar los servicios o recursos afectados.

## AI y SimpleBrain

Secuencia de sesión y destilación: `sbs/af → afl (optional) → sbsb/sbo → sbe/afx → aflastdraft/afapplylast`.

Nota de compatibilidad: `.bash_grammar` conserva etiquetas históricas para
`sbo`/`sbs`/`sbsb` que no coinciden con el runtime observado. Esta guía
describe el runtime y no modifica el catálogo; la reconciliación del catálogo
queda pendiente de una fase posterior.

| Propósito | Alcance de mutación | Validación |
| --- | --- | --- |
| Iniciar una sesión, lanzar opcionalmente un agente, consultar estado, cerrar el ciclo y localizar o aplicar el último draft. | `af` y `afl` preparan contexto; `sbs` inicia una sesión y cambia el estado de sesión; `sbsb` inicia una sesión nueva instrumentada con `AI_SESSION_BENCH=1`; `sbo` solo lee la sesión activa y sus candidatas; `sbe`, `afx` y `afapplylast` cambian la sesión o aplican resultados. | Usa `sbo` para consultar estado o candidatas, `sbs` para iniciar y `aflastdraft` para revisar el draft; aplica `afapplylast` solo tras comprobar el contenido y validar el resultado en el proyecto. |

Cancela el selector si el proyecto o la sesión no son inequívocos. Rechaza
cualquier confirmación de aplicación o cierre cuando el draft o el siguiente
paso no correspondan a la tarea actual.

## Salidas seguras y validación

- `gs`, `gd`, `gds`, `docps`, `dps`, `ports`, `dlogs`, `topme`, `sbo` y `aflastdraft` sirven para inspeccionar antes de mutar; `sbs` inicia una sesión y `sbsb` inicia una sesión nueva instrumentada.
- Después de cambiar código o servicios, usa `rtest`; para calidad completa usa `qa` o `rqa`.
- Un selector cancelado no debe ejecutar una acción posterior. Una confirmación rechazada debe dejar intacto el estado objetivo.
- `pbcopy` copia stdin al portapapeles y `pbpaste` lo lee; son wrappers públicos definidos en `.bashrc`, fuera del catálogo generado.
- `z` es la función dinámica producida por `zoxide init bash`; no debe renombrarse ni reimplementarse.

## Referencias

- [BASH_SHORTCUTS.md](../BASH_SHORTCUTS.md)
- [Auditoría de comandos Bash (2026-08-31)](audits/2026-08-31-bash-command-audit.md)
- [Baseline de rendimiento Bash (2026-09-01)](baselines/bash-performance-2026-09-01.md)
- [Diseño de gramática operativa Bash (2026-09-01)](superpowers/specs/2026-09-01-bash-operational-grammar-design.md)
