# Checklist de validación Bash — Fase 4

Checklist de cierre para validar la experiencia completa en Kitty, i3, tmux y
Bash. Registrar una fila por prueba; no leer historial privado ni tocar
`.bashrc_local` (ni siquiera para inspeccionarlo).

## 1. Precondiciones y baseline

- [ ] Trabajar desde `/home/acuervo/dotfiles`, con una copia de trabajo
  identificada y sin incluir secretos, contenido de `.env`, portapapeles ni
  historial en capturas o registros.
- [ ] Registrar fecha, rama, `git status --short` y los SHA de referencia.
  Comparar el rendimiento con el [baseline de rendimiento Bash](baselines/bash-performance-2026-09-01.md);
  repetir la medición dentro de Kitty, con y sin tmux, antes de proponer
  optimizaciones.
- [ ] Confirmar que las pruebas manuales se hacen en un proyecto de prueba o
  en un proyecto cuyo estado inicial esté entendido; cancelar selectores y
  rechazar confirmaciones cuando no se quiera mutar nada.

| Prueba | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| Precondiciones + captura de baseline | Contexto reproducible, sin datos privados expuestos | | | |

## 2. Pruebas automáticas disponibles

Ejecutar desde la raíz del repositorio. La suite no debe leer ni imprimir el
contenido real de `.bashrc_local`.

```bash
set -e
for test in tests/bash_*_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile \
  stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh \
  scripts/generate_bash_shortcuts.sh; do bash -n "$file"; done
bash ./scripts/generate_bash_shortcuts.sh
git diff --exit-code -- BASH_SHORTCUTS.md
git diff --check
```

| Prueba | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| `for test in tests/bash_*_test.sh; do bash "$test"; done` | Todos los tests disponibles terminan con código 0 | | | |
| `bash -n` sobre Bash, librerías y generador | No hay errores de sintaxis | | | |
| Generador de `BASH_SHORTCUTS.md` + diff | Generación idempotente; el catálogo no cambia | | | |
| `git diff --check` | Sin errores de whitespace | | | |

## 3. Checklist manual por contexto

En cada fila, anotar la fecha, `PASS`/`FAIL`/`N/A` y cualquier fricción
observable. No convertir una observación en un cambio de binding: consultar la
[matriz de ownership](bash-context-key-matrix.md), los
[workflows](bash-workflows.md) y la [guía de memoria muscular](bash-muscle-memory.md).

Para comprobar ausencia real, guardar el `PATH` original y usar un `PATH`
temporal que omita el directorio del ejecutable bajo prueba, sin añadir ningún
stub. Esto no renombra, elimina ni desinstala lo instalado. Sólo si se quiere
probar un diagnóstico concreto, usar en un directorio binario separado un
wrapper/stub que falle de forma controlada; un stub es un fallo simulado, no
ausencia real. En ambos casos usar `trap` para restaurar el entorno y limpiar
los temporales al terminar, sin cambiar configuración permanente. Después de
cada prueba, verificar explícitamente que `HOME`/XDG temporales ya no existen
y que `HOME`, `PATH`, configuración y archivos del entorno original siguen
intactos.

Cuando ble.sh o bash-completion se carguen desde una ruta absoluta, un `PATH`
temporal no basta: derivar un `--rcfile` temporal a partir del rc real,
sustituyendo u omitiendo únicamente las líneas de ese componente. Arrancar
Bash con ese `--rcfile`, verificar que inicia correctamente, y usar `trap EXIT`
para restaurar el entorno y borrar la copia temporal; no tocar los archivos
instalados ni ninguna configuración permanente. En todo procedimiento con
`--rcfile`, crear además un `HOME` temporal, fijar `HISTFILE` a un archivo
dentro de él y usar `XDG_CONFIG_HOME` y `XDG_DATA_HOME` temporales. El rc
temporal debe omitir la línea que sourcea `.bashrc_local` y ese `HOME` no debe
contenerlo.

Para hacer el aislamiento accionable, guardar los valores originales sólo en
variables shell temporales, neutralizar en una shell hija cualquier variable
`ATUIN_*` heredada antes de probar Atuin (revisar y limpiar toda variable cuyo
valor pueda apuntar a datos reales), y conservar el `PATH` original sin
escribirlo en archivos. El `trap EXIT` debe restaurar `HOME`, `HISTFILE`, XDG,
`PATH` y las variables `ATUIN_*`, eliminar rc/HOME/XDG/directorios binarios
temporales y, después, verificar que esas rutas ya no existen y que el entorno
real sigue intacto.

| Prueba | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| Nueva sesión Kitty + login | La sesión login carga el entorno esperado, sin errores ni datos privados en pantalla | | | |
| Nueva sesión Kitty + no-login | La sesión interactiva carga Bash y sus funciones esperadas, sin errores | | | |
| Recarga de Bash | Recargar el entorno una o más veces no duplica funciones, aliases, PATH ni hooks | | | |
| Clipboard | Copiar y pegar una cadena de prueba funciona; no se captura ni se muestra ningún dato privado | | | |
| Atuin | Antes de ejecutar, neutralizar toda variable heredada `ATUIN_*` que pueda apuntar a datos reales; ejecutar literalmente con `HOME=...` temporal, `HISTFILE=...` dentro de ese `HOME`, `XDG_CONFIG_HOME=...` temporal y `XDG_DATA_HOME=...` temporal; usar `trap EXIT` con restauración, verificación de que no quedan rutas y limpieza; inicializar una base nueva; insertar dos entradas sintéticas mediante el mecanismo de ingestión documentado por la versión instalada, registrando el comando exacto y su salida; consultar exclusivamente esa base y comprobar que devuelve esas dos entradas. Si no hay ingestión aislada, marcar `N/A` con motivo. Nunca usar `HOME` ni historial reales | | | |
| FZF | Selectores previstos abren, cancelan con seguridad y no mutan al cancelar | | | |
| ble.sh | Edición interactiva y keymap efectivo funcionan; verificar ownership contra la [matriz](bash-context-key-matrix.md) | | | |
| Completado | `Tab` completa comandos/rutas disponibles sin errores; comprobar también el comportamiento de completado relevante | | | |
| Navegación tmux | Crear/seleccionar/cerrar panes o ventanas y salir de copy-mode según el keymap efectivo; no asumir bindings nuevos | | | |
| Workspaces i3 | Cambiar entre workspaces, usar scratchpad y volver al estado inicial; confirmar que no se cierran ventanas por accidente | | | |
| Polybar | La barra muestra los módulos esperados, sin errores visibles ni pérdida de workspace/estado | | | |
| Workflow backend | Seguir el recorrido seguro de backend en [bash-workflows.md](bash-workflows.md#backend-php): inspeccionar, actuar sólo si procede y validar | | | |
| Workflow servidores | Seguir el recorrido de [servidores](bash-workflows.md#servidores); puertos, procesos y logs coinciden con el estado observado | | | |
| Workflow Git | Seguir el recorrido de [Git](bash-workflows.md#git); revisar estado/diffs antes de cualquier staging o commit y rechazar confirmaciones sensibles cuando proceda | | | |
| Workflow Docker | Seguir el recorrido de [Docker](bash-workflows.md#docker); inspeccionar Compose/contenedores antes de operar y validar al final | | | |
| Workflow AI | Seguir el recorrido de [AI y SimpleBrain](bash-workflows.md#ai-y-simplebrain); consultar estado/drafts antes de aplicar y cancelar si no son inequívocos | | | |
| Opcional Atuin: sintético + ausencia real | Ejecutar la prueba Atuin sintética con `HOME=...` temporal, `HISTFILE=...` dentro de ese `HOME`, `XDG_CONFIG_HOME=...` temporal y `XDG_DATA_HOME=...` temporal; neutralizar `ATUIN_*`; usar `trap EXIT` con restauración, verificación de que `HOME`/XDG temporales ya no existen y limpieza. Para ausencia real, repetir con un `PATH` que omita el directorio de Atuin y sin stub. Nunca usar `HOME` ni historial reales | La base temporal devuelve sólo las dos entradas sintéticas; sin Atuin, Bash carga y diagnostica el fallback sin errores; el historial real y el entorno original permanecen intactos | | |
| Opcional ausente: FZF | Para ausencia real, usar un `PATH` temporal que omita el directorio de FZF, sin stub; ejecutar literalmente con `HOME=...` temporal, `HISTFILE=...` dentro de ese `HOME`, `XDG_CONFIG_HOME=...` temporal y `XDG_DATA_HOME=...` temporal; si se carga rc, usar una copia temporal que omita la línea de `.bashrc_local`; neutralizar `ATUIN_*`; usar `trap EXIT` con restauración del entorno, verificación de que `HOME`/XDG temporales ya no existen y limpieza; abrir cada selector previsto y cancelarlo. No instalar ni alterar configuración permanente | Bash carga; cada selector falla o se omite con diagnóstico limpio y sin mutación; el entorno original permanece intacto | | |
| Opcional ausente: ble.sh | Como ble.sh usa ruta absoluta, crear `HOME` temporal con `HISTFILE` dentro, XDG temporales y rc temporal derivado del rc real omitiendo sólo sus líneas y la de `.bashrc_local`; arrancar Bash con `--rcfile`, verificarlo, sin cargar ble.sh; usar `trap EXIT`, restaurar variables, comprobar que no quedan rutas y que el entorno real está intacto. No tocar archivos instalados ni configuración permanente | Bash arranca correctamente, conserva Readline/keymap soportados y diagnostica la ausencia sin errores | | |
| Opcional ausente: completado | Como bash-completion usa ruta absoluta, crear `HOME` temporal con `HISTFILE` dentro, XDG temporales y rc temporal derivado del rc real omitiendo sólo sus líneas y la de `.bashrc_local`; arrancar Bash con `--rcfile` y probar `Tab` sobre comando/ruta de prueba; usar `trap EXIT`, restaurar variables, comprobar que no quedan rutas y que el entorno real está intacto. No instalar ni modificar configuración permanente | Bash arranca correctamente y el completado ausente se degrada limpiamente, sin errores inesperados | | |
| Diagnóstico limpio | No aparecen errores inesperados al iniciar, recargar, abrir Kitty/tmux ni ejecutar los recorridos | | | |

## 4. Criterios de salida

- [ ] Todas las pruebas automáticas pasan; el generador es idempotente y
  `git diff --check` está limpio.
- [ ] Cada prueba manual tiene fecha y resultado. Los `N/A` incluyen motivo;
  cada `FAIL` tiene incidencia, evidencia no sensible y decisión explícita.
- [ ] Login, no-login y reload son repetibles; clipboard no expone datos;
  Atuin/FZF/ble.sh/completado y los contextos Kitty+i3+tmux son utilizables.
- [ ] Los workflows siguen los documentos existentes y no introducen nombres
  o bindings no documentados. No se lee historial privado ni se modifica
  `.bashrc_local`.
- [ ] La ausencia de opcionales produce degradación esperada y diagnóstico
  limpio. El rendimiento queda dentro del presupuesto provisional del
  baseline, o la desviación queda documentada para la siguiente fase.

## 5. Segunda auditoría tras uso real

Tras un periodo de uso real, repetir esta checklist y completar otra fecha de
resultado. Revisar especialmente fricciones de reload, completado, clipboard,
tmux/i3 y workflows. Sólo entonces proponer retirar, renombrar o cambiar un
comando o binding; cualquier propuesta debe actualizar primero la
documentación de referencia correspondiente.

| Revisión posterior | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| Auditoría tras periodo de uso | Sin regresiones no explicadas; fricciones clasificadas y decisiones documentadas | | | |
