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
| `bash tests/bash_*_test.sh` | Todos los tests disponibles terminan con código 0 | | | |
| `bash -n` sobre Bash, librerías y generador | No hay errores de sintaxis | | | |
| Generador de `BASH_SHORTCUTS.md` + diff | Generación idempotente; el catálogo no cambia | | | |
| `git diff --check` | Sin errores de whitespace | | | |

## 3. Checklist manual por contexto

En cada fila, anotar la fecha, `PASS`/`FAIL`/`N/A` y cualquier fricción
observable. No convertir una observación en un cambio de binding: consultar la
[matriz de ownership](bash-context-key-matrix.md), los
[workflows](bash-workflows.md) y la [guía de memoria muscular](bash-muscle-memory.md).

| Prueba | Resultado esperado | Fecha | Resultado | Observaciones |
| --- | --- | --- | --- | --- |
| Nueva sesión Kitty + login | La sesión login carga el entorno esperado, sin errores ni datos privados en pantalla | | | |
| Nueva sesión Kitty + no-login | La sesión interactiva carga Bash y sus funciones esperadas, sin errores | | | |
| Recarga de Bash | Recargar el entorno una o más veces no duplica funciones, aliases, PATH ni hooks | | | |
| Clipboard | Copiar y pegar una cadena de prueba funciona; no se captura ni se muestra ningún dato privado | | | |
| Atuin | Historial interactivo funciona con la configuración vigente; no se inspecciona historial privado | | | |
| FZF | Selectores previstos abren, cancelan con seguridad y no mutan al cancelar | | | |
| ble.sh | Edición interactiva y keymap efectivo funcionan; verificar ownership contra la [matriz](bash-context-key-matrix.md) | | | |
| Completado | `Tab` completa comandos/rutas disponibles sin errores; comprobar también el comportamiento de completado relevante | | | |
| Navegación tmux | Crear/seleccionar/cerrar panes o ventanas y salir de copy-mode según el keymap efectivo; no asumir bindings nuevos | | | |
| Workspaces i3 | Cambiar entre workspaces, usar scratchpad y volver al estado inicial; confirmar que no se cierran ventanas por accidente | | | |
| Polybar | La barra muestra los módulos esperados, sin errores visibles ni pérdida de workspace/estado | | | |
| Workflow backend | Seguir el recorrido seguro de backend en [bash-workflows.md](bash-workflows.md): inspeccionar, actuar sólo si procede y validar | | | |
| Workflow servidores | Usar el recorrido de servidores existente; puertos, procesos y logs coinciden con el estado observado | | | |
| Workflow Git | Revisar estado/diffs antes de cualquier staging o commit; las confirmaciones sensibles se pueden rechazar | | | |
| Workflow Docker | Inspeccionar Compose/contenedores antes de operar; logs y validación final son coherentes | | | |
| Workflow AI | Consultar estado/drafts antes de aplicar; cancelar o rechazar cuando proyecto, sesión o draft no sean inequívocos | | | |
| Dependencias opcionales ausentes | Deshabilitar o simular ausencia de Atuin, FZF, ble.sh, completado y otros opcionales: Bash sigue cargando y diagnostica la omisión limpiamente | | | |
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
