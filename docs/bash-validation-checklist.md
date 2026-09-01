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

Para simular opcionales ausentes, crear un directorio binario temporal y
anteponerlo a `PATH`. Dejar allí wrappers/stubs que devuelvan ausencia limpia o
un código controlado para el componente bajo prueba; no renombrar, eliminar ni
desinstalar ejecutables instalados. Ejecutar la sesión con ese `PATH`, sin
cambiar configuración permanente, restaurar el `PATH` original al terminar y
eliminar el directorio temporal.

| Prueba | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| Nueva sesión Kitty + login | La sesión login carga el entorno esperado, sin errores ni datos privados en pantalla | | | |
| Nueva sesión Kitty + no-login | La sesión interactiva carga Bash y sus funciones esperadas, sin errores | | | |
| Recarga de Bash | Recargar el entorno una o más veces no duplica funciones, aliases, PATH ni hooks | | | |
| Clipboard | Copiar y pegar una cadena de prueba funciona; no se captura ni se muestra ningún dato privado | | | |
| Atuin | Crear un directorio temporal, ejecutar con `HOME`, `XDG_CONFIG_HOME` y `XDG_DATA_HOME` temporales, escribir dos entradas sintéticas, ingerirlas con el subcomando disponible (`atuin help`; por ejemplo `atuin import auto`), consultarlas y eliminar todo; nunca usar `HOME` ni historial reales | | | |
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
| Opcional Atuin: sintético + ausente | Con Atuin disponible, seguir la prueba sintética anterior dentro del entorno temporal; después anteponer al `PATH` un stub de ausencia, iniciar otra sesión temporal, restaurar el `PATH` y limpiar ambos temporales. Nunca usar `HOME` ni historial reales | La búsqueda devuelve sólo las entradas sintéticas; sin Atuin, Bash carga y diagnostica el fallback sin errores, y el historial real permanece intacto | | |
| Opcional ausente: FZF | Aplicar el `PATH` binario temporal con wrapper/stub de ausencia, abrir cada selector previsto, cancelarlo, restaurar el `PATH` original y eliminar el directorio temporal; no instalar ni alterar configuración permanente | Bash carga; cada selector falla o se omite con diagnóstico limpio y sin mutación | | |
| Opcional ausente: ble.sh | Aplicar el `PATH` binario temporal con wrapper/stub controlado, iniciar una sesión sin cargar ble.sh, comprobar la edición Readline y el keymap efectivo, restaurar el `PATH` y limpiar el temporal; no cambiar configuración permanente | Bash conserva edición/completado soportados y diagnostica la ausencia sin errores | | |
| Opcional ausente: completado | Aplicar el `PATH` binario temporal con wrapper/stub de ausencia, iniciar sin cargar bash-completion, probar `Tab` sobre un comando y una ruta de prueba, restaurar el `PATH` y limpiar el temporal; no instalar ni modificar configuración permanente | Bash carga y el completado ausente se degrada limpiamente, sin errores inesperados | | |
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
