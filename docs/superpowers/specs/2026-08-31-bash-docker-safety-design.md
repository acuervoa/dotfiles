# Bash Docker/Laravel Safety Design

## Objetivo

Proteger operaciones Docker/Laravel con impacto en datos, cachés o tiempo de
desarrollo, manteniendo instantáneos los comandos de consulta, ejecución y
testing.

## Estado confirmado

- `pmig` ejecuta migraciones sin confirmación.
- `pseed` ejecuta seeders sin confirmación.
- `pclear` limpia varias cachés sin confirmación.
- `dorebuild` ejecuta `build --no-cache` y `up -d` sin confirmación.
- Puede existir además un alias `dcrb` equivalente al rebuild rápido.
- `pcc` y `pcf` afectan cachés/configuración, pero no se consideran operaciones
  de datos en esta fase.
- `p`, `part`, `ptest`, `pstan`, `pint`, `proute`, `docps`, `dlogs` y `dsh` se
  mantienen rápidos.

## Diseño elegido

Se añadirán confirmaciones negativas antes de ejecutar `pmig`, `pseed`,
`pclear` y el rebuild sin caché. La confirmación ocurrirá antes de resolver el
proyecto Compose para evitar trabajo y efectos secundarios cuando el usuario
rechace.

Si `dcrb` es un alias, se convertirá en función y conservará exactamente la
secuencia `docker compose build --no-cache` seguida de `docker compose up -d`.
`dorebuild` conservará su nombre y delegará en la misma lógica protegida, sin
crear dos implementaciones distintas.

No se añadirá detección heurística de producción. La configuración actual no
ofrece un contrato fiable para distinguir desarrollo de producción, y una
detección parcial podría bloquear usos válidos o dar falsa seguridad.

## Compatibilidad

- Se mantienen todos los nombres públicos actuales.
- Las operaciones protegidas pasan a requerir `y` explícito; cualquier otra
  respuesta aborta sin invocar Docker.
- Se preservan los argumentos adicionales de cada comando.
- No se modifican `.env`, Docker real, tmux, i3 ni `.bashrc_local`.

## Validación

Se probarán funciones con wrappers falsos de `docker`/`docker-compose`. Para
cada operación protegida, `n` debe producir cero invocaciones y `y` debe
conservar los argumentos exactos. También se probará que los comandos rápidos
siguen delegando sin confirmación.

## Fuera de alcance

- Detección de entornos de producción.
- Confirmación para `pcc` o `pcf`.
- Cambiar la arquitectura de Compose.
- Revisar todavía `dclean`, `envswap` u otras órdenes fuera de esta subfase.
