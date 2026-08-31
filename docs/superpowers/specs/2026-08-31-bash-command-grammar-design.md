# Bash Command Grammar Design

## Objetivo

Hacer que la memoria muscular de Bash se apoye en familias semánticas y una
capa pequeña de atajos de una tecla, sin renombrar comandos existentes ni
introducir fricción en operaciones seguras.

## Inventario confirmado

- `g*`: Git.
- `d*`: Docker/Compose.
- `p*`: PHP/Laravel.
- `r*`: runtime, QA y repetición.
- `af*`: AI Flow.
- `sb*`: SimpleBrain y sesiones AI.
- Utilidades de navegación, sistema y consulta permanecen con nombres
  descriptivos propios.
- Atajos de una tecla actuales: `l`, `n`, `p`, `r`, `y`, `z`.
- No hay colisiones detectadas con builtins de Bash.
- `r` edita y confirma el penúltimo comando; `redo` lo ejecuta directamente.
  Son contratos distintos y se mantienen separados.

## Diseño elegido

No se renombrarán comandos públicos. Se añadirán metadatos de grupo y riesgo a
las funciones documentadas mediante comentarios `@cmd`, y se anotarán también
los aliases públicos relevantes.

`dothelp` se ampliará para mostrar funciones y aliases agrupados por familia,
con una indicación de riesgo cuando una orden pide confirmación o puede mutar
datos. Los comandos AI y SimpleBrain tendrán cobertura explícita.

Se generará `BASH_SHORTCUTS.md` desde una fuente declarativa o un extractor
determinista de la configuración existente. Cada entrada incluirá nombre,
grupo, descripción, riesgo y ejemplo breve. El documento no contendrá valores
de entorno ni argumentos sensibles.

Se añadirá un linter/test que compruebe que cada comando público documentado
tiene grupo, que no existen owners duplicados en los módulos versionados y que
los atajos de una tecla siguen siendo los esperados.

## Capas de uso

1. **Micro:** `l`, `n`, `p`, `r`, `y`, `z` para acciones frecuentes.
2. **Familias:** `g*`, `d*`, `p*`, `r*`, `af*`, `sb*` para acciones de dominio.
3. **Descubrimiento:** `dothelp` y `BASH_SHORTCUTS.md` para órdenes menos
   frecuentes.

## Compatibilidad y alcance

- No cambian tmux, i3, `.bashrc_local` ni secretos.
- No se cambia la semántica de `r`, `redo` ni de los comandos protegidos.
- El documento generado debe ser reproducible y estable.
- No se añadirán nuevos atajos funcionales en esta fase.

## Validación

Se probará el extractor/linter contra la configuración real, se comprobará la
ausencia de duplicados y se comparará el runtime de los atajos antes y después
de dos reloads. También se verificará que la documentación no contiene
patrones de secretos.

## Fuera de alcance

- Rediseñar nombres o eliminar comandos legacy.
- Añadir funcionalidades nuevas.
- Cambiar bindings de tmux/i3.
- Automatizar todavía el aprendizaje o las estadísticas de frecuencia.
