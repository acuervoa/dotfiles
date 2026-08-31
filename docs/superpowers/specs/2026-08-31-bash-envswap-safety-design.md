# Bash envswap Safety Design

## Objetivo

Evitar activar accidentalmente un entorno `.env` y garantizar que los backups
sean recuperables, privados y no se sobrescriban.

## Estado confirmado

- `envswap list` enumera `.env.*` sin modificar nada.
- `envswap use NOMBRE` valida el origen, copia el `.env` actual a un backup y
  activa `.env.<NOMBRE>`.
- El cambio actual no pide confirmación.
- El backup usa sólo segundos en el nombre, por lo que puede colisionar.
- Backup y `.env` activo reciben permisos `600` cuando el sistema lo permite.

## Diseño elegido

`envswap list` se mantiene instantáneo.

`envswap use NOMBRE` seguirá validando primero que `.env.NOMBRE` sea un fichero
regular. Después mostrará sólo las rutas implicadas y pedirá confirmación
negativa. Una respuesta distinta de `y` abortará sin copiar ni modificar
ficheros.

Cuando exista `.env`, se creará un backup con timestamp y PID, por ejemplo
`.env.bak.20260831-153000.1234`, evitando sobrescrituras dentro del mismo
segundo. El backup y el `.env` activo conservarán permisos `600`.

No se imprimirá ni comparará en pantalla el contenido de ningún `.env`; los
tests podrán usar `cmp` internamente sobre ficheros temporales.

## Compatibilidad

- Se mantienen `envswap list` y `envswap use NOMBRE`.
- Se mantienen los mensajes de uso y la ruta relativa al proyecto actual.
- Se añade únicamente una confirmación para `use`.
- No se modifica `.bashrc_local`, tmux, i3, Docker ni Laravel.

## Validación

Se usará un directorio temporal con `.env`, `.env.staging` y `.env.production`.
Se probará rechazo sin cambios, activación confirmada con contenido y permisos
correctos, y dos swaps consecutivos con backups distintos. Ningún test mostrará
contenido de los ficheros.

## Fuera de alcance

- Cifrar backups.
- Gestionar secretos mediante un vault externo.
- Añadir detección de producción.
- Cambiar `envswap list` o la nomenclatura pública.
