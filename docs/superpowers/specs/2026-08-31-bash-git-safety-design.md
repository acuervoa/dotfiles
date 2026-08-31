# Bash Git Safety Design

## Objetivo

Reducir el riesgo de operaciones Git destructivas o difíciles de revertir sin
romper la memoria muscular de las órdenes frecuentes.

## Estado confirmado

- `gundo` ya pide confirmación antes de `git reset --soft HEAD~1`.
- `gclean` ya pide confirmación antes de borrar ramas mergeadas.
- `gp` ya pide confirmación para push normal y force push.
- `gpf` es un alias directo a `git push --force-with-lease` y no pide confirmación.
- `ga` sólo prepara cambios; se mantiene rápido porque el staging es reversible.

## Diseño elegido

### `gpf`

Sustituir el alias por una función pública con el mismo nombre. Mostrará la rama
actual, indicará que se usará `--force-with-lease`, pedirá confirmación por
defecto negativa y sólo ejecutará el push tras una respuesta afirmativa.

La operación seguirá usando exactamente `git push --force-with-lease`, sin
añadir `--force` ni modificar el upstream.

### `wip`

Mantener el flujo rápido, pero inspeccionar los nombres de archivos staged antes
del commit. Si aparecen patrones de alto riesgo (`.env`, claves, tokens o
credenciales), la función abortará y pedirá retirar esos archivos. No se
imprimirá el contenido de ningún fichero.

### Comandos ya protegidos

No se modificarán `gp`, `gundo` ni `gclean`; se añadirán pruebas para fijar su
contrato existente sólo si resulta necesario para la suite.

## Compatibilidad

- Los nombres públicos permanecen iguales.
- `gpf` cambia de alias a función, pero conserva su invocación sin argumentos.
- No se tocarán tmux, i3, Docker, Laravel ni `.bashrc_local`.
- No se introducirán confirmaciones para `ga`.

## Validación

Se usará un repositorio temporal y un wrapper controlado de `git` para probar
que `gpf` no ejecuta push ante rechazo y que usa `--force-with-lease` ante
confirmación. Se probará también que `wip` bloquea nombres sensibles y permite
un conjunto normal de archivos. Se ejecutará la suite Bash completa y `bash -n`
antes del commit.

## Fuera de alcance

- Rediseñar la nomenclatura completa `g*`.
- Añadir confirmaciones a cada staging.
- Cambiar el comportamiento de `checkpoint`, `fixup` o `envswap`.
- Revisar todavía Docker/Laravel.
