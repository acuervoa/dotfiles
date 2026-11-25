# wl: registro de trabajo por equipo

`wl` (`stow/bin/.local/bin/wl`) es un script Python de biblioteca estándar que
guarda un registro de trabajo en ficheros JSONL, uno por equipo y día, dentro de
un repositorio git. Este documento describe solo comportamiento comprobado en el
código y en `tests/wl_test.sh`.

## Comandos

| Forma | Efecto |
| --- | --- |
| `wl [-a NOMBRE] [-l\|-d\|-b] "texto"` | añade una entrada (por defecto `hecho`; `-l` aprendizaje, `-d` decisión, `-b` bloqueo) |
| `wl today` | entradas de hoy de todos los equipos |
| `wl sync` | `add` + commit del directorio de este equipo, `pull --rebase` y `push` |
| `wl init GIT_URL [--host NOMBRE]` | clona el repositorio y, con `--host`, fija el nombre del equipo |
| `wl daily --vault RUTA [--date AAAA-MM-DD]` | vuelca el día en `RUTA/DAILY/<fecha>.md` |

Desambiguación (`is_command`): una frase que empieza por un subcomando es una
entrada salvo que tenga exactamente la forma del comando.

- `today` y `sync` son comando solo sin más argumentos (`wl sync terminado con X` es una entrada).
- `daily` es comando sin argumentos, con `--flag` como primer argumento o con una fecha `AAAA-MM-DD`
  suelta; `wl daily` sin `--vault` responde con el error de uso (rc=1). Cualquier otra frase
  (`wl daily me cansé`, `wl daily -x`) es una entrada.
- `init` es comando si el primer argumento es `--host` o no empieza por `-` y contiene `:` o `/`.
- `-a NOMBRE` y `-l/-d/-b` solo son flags al inicio; después de la primera palabra son texto.

## Formato JSONL

Fichero `<WORKLOG_DIR>/<equipo>/AAAA-MM-DD.jsonl`, una línea JSON por entrada:

```json
{"id":"a1b2c3d4e5f6","ts":"2026-10-19T09:05:00+02:00","host":"equipo","tipo":"hecho","texto":"..."}
```

- Campos obligatorios, todos cadenas: `id` (12 hex aleatorios), `ts` (ISO 8601 con offset), `host`,
  `tipo` (`hecho`, `aprendizaje`, `decision`, `bloqueo`) y `texto` (espacios colapsados).
- Campo opcional `agente`: solo existe si hay agente (`-a` o `WORKLOG_AGENT`); la clave se omite, nunca es `null`.
- La compatibilidad con el lector original `dfdd782` está limitada a lo que cubre la sección 10 del test:
  ese lector lee un log con `agente` sin avisos ni pérdida de entradas.

## Entorno

| Variable | Efecto |
| --- | --- |
| `WORKLOG_DIR` | raíz de datos (por defecto `~/.local/share/worklog`) |
| `WORKLOG_HOST` | nombre del equipo; gana a la configuración |
| `$XDG_CONFIG_HOME/worklog/host` (por defecto `~/.config/worklog/host`) | nombre del equipo si no hay `WORKLOG_HOST`; si tampoco existe, el hostname |
| `WORKLOG_AGENT` | agente por defecto; `-a` tiene prioridad; vacío equivale a ausente |

Nombres de equipo y de agente: `^[A-Za-z0-9][A-Za-z0-9._-]*$` (sin `/` ni espacios). Un nombre
no válido da rc=1 sin escribir nada. `wl` no comprueba que dos máquinas no usen el mismo nombre.

## Códigos de salida y salidas

- rc=1: uso incorrecto o estado que impide la operación (texto vacío, nombre no válido, no hay
  repositorio, cambios fuera del directorio del equipo, marcadores de la daily incompletos...).
- rc=2: `wl sync` con fallo de pull o push (sin red, conflicto) o repositorio sin commits.
- `wl init`: si `git clone` falla, devuelve el código de git (p. ej. 128); el resto de errores, 1.
- `wl today` devuelve 0 también sin entradas (`sin entradas hoy`).
- Errores y avisos van a stderr con prefijo `wl:`; los resultados (`HH:MM ✅ hecho · texto`,
  `sincronizado`, `listo: equipo=… datos=…`, la salida de `today` y `daily`) van a stdout.

## Garantías

- Escritura: `O_APPEND` + `fsync`; solo se añaden líneas y cada equipo escribe en su directorio.
- Lectura tolerante: una línea que no es JSON, no tiene los 5 campos como cadena o tiene `ts` no
  interpretable se omite con `wl: aviso: línea inválida <equipo>/<fichero>:<n>` en stderr; las líneas
  en blanco se ignoran sin aviso; los campos extra no invalidan la línea; un `ts` sin offset se toma
  como hora local. Las entradas se deduplican por `id` (gana la última leída) y se ordenan por `ts`.
- `wl daily` solo reemplaza lo que hay entre `<!-- worklog:start -->` y `<!-- worklog:end -->`; sin
  marcadores añade el bloque al final; es idempotente (`sin cambios`); conserva CRLF; si la nota es un
  enlace simbólico actualiza el destino; con marcadores incompletos o desordenados no toca la nota (rc=1).
  Dentro del bloque `<!--` se escribe `&lt;!--`, `-->` se escribe `--&gt;` y el backtick se sustituye por `'`.
  La nota debe existir: `wl daily` no la crea.

## Decisión D3

`wl daily` y `wl sync` no se automatizan: uso manual, sin timers, hooks ni servicios.

## Adopción de datos locales en `wl init`

Caso: `wl "entrada"` se ejecutó antes de `wl init`, y `<WORKLOG_DIR>` ya contiene `<equipo>/`.
`wl init` lo adopta sin borrar ni mover nada a mano.

**Es adoptable** solo si `<WORKLOG_DIR>` es un directorio real (no enlace) en el mismo dispositivo que
su padre, tiene exactamente un hijo, ese hijo es un directorio real y dentro solo hay ficheros regulares
`AAAA-MM-DD.jsonl` (o está vacío). Cualquier otra cosa (`.git`, ficheros sueltos, otros directorios,
enlaces, subdirectorios, otros nombres) no es adoptable: `wl: <ruta> ya existe y no está vacío` (rc=1,
con una pista en el mismo mensaje) y no se toca nada. Si el directorio no existe o está vacío se clona
directamente, sin nota de adopción.

**Nombre efectivo:** `WORKLOG_HOST` si está definido, si no `--host`, si no el de la configuración o el
hostname. Debe ser válido y coincidir con el nombre del directorio local; si no, rc=1 con
«hay datos locales de X/; usa --host X o WORKLOG_HOST=X». `wl` no renombra ni reescribe datos.
Si `WORKLOG_HOST` y `--host` están ambos presentes y difieren, la adopción se rechaza (ver «Rechazos»).

**Rechazos sin modificar nada local** (temporal borrado):

- `WORKLOG_HOST` y `--host` definidos a la vez con valores distintos (rc=1,
  `wl: WORKLOG_HOST=X y --host Y difieren; usa el mismo valor en ambos o elimina uno`): solo en la
  adopción, antes de crear clon, temporal o configuración. Con valores iguales, o con solo uno de los
  dos, no hay rechazo. La inicialización convencional (`<WORKLOG_DIR>` inexistente o vacío) no cambia;
- el remoto ya contiene `<equipo>/` (rc=1): no se adopta ni se mezcla;
- las exclusiones de Git del repositorio clonado (`.gitignore`, `.git/info/exclude`, excludes globales)
  ignorarían `<equipo>/` o sus ficheros (rc=1): `wl sync` no los publicaría. `wl` no modifica `.gitignore` ni usa `add --force`;
- `git clone` falla (rc de git, p. ej. 128).

**Resultado:** el clon pasa a ser `<WORKLOG_DIR>` y `<equipo>/` queda como directorio sin seguimiento
(`?? <equipo>/`). Las entradas quedan sin confirmar hasta ejecutar `wl sync`. En stderr aparece una nota:
`wl: adoptadas entradas locales de <equipo>/ (sin confirmar; wl sync las publica)`.

**Mecánica:** se clona en `.<nombre-de-root>.init-XXXX` (hermano de `<WORKLOG_DIR>`), se escribe el
marcador `ADOPTING` (con el nombre del equipo), se mueve `<equipo>/` dentro del clon y el clon pasa a
ser `<WORKLOG_DIR>` (dos `rename`).

**Recuperación:**

- Desde que se intenta mover `<equipo>/` al clon (primer `rename`), el temporal no se borra salvo que
  se acredite que los datos siguen en `<WORKLOG_DIR>/<equipo>` y no están en el clon. Una interrupción
  (p. ej. Ctrl-C) o un error tras mover los datos no los borra: quedan en
  `.<root>.init-XXXX/clone/<equipo>`.
- Si el primer `rename` falla con los datos sin mover (acreditado), se borra el temporal (rc=1). Si falla
  en estado incierto (los datos pueden estar en `<WORKLOG_DIR>/<equipo>` o en `clone/<equipo>`), se
  conserva el temporal y el mensaje (rc=1) da ambas rutas y la recuperación manual: localizar los datos,
  devolverlos a `<WORKLOG_DIR>/<equipo>` y borrar el temporal. Mientras exista, `wl init` se niega.
- Si el segundo `rename` falla y los datos pueden devolverse, se restauran y, si se acredita la restauración, se borra el temporal (rc=1); si no se puede acreditar, se conserva y se informa.
- Si no pueden devolverse (por ejemplo `<WORKLOG_DIR>/<equipo>` se recreó con otras entradas), no se borra
  nada: los datos originales quedan en `.<root>.init-XXXX/clone/<equipo>` y los nuevos en
  `<WORKLOG_DIR>/<equipo>`. El mensaje da ambas rutas; hay que combinarlos a mano y borrar el temporal.
  Mientras ese temporal (con `ADOPTING` y `clone/<equipo>`) exista, `wl init` se niega (rc=1), aunque
  `<WORKLOG_DIR>` no exista o esté vacío. Un temporal sin `ADOPTING`, o sin `clone/<equipo>`, no bloquea.
- Si la adopción se completó pero falla escribir la configuración (`--host`), `wl init` sale con rc=1 sin
  mensaje de éxito y sin deshacer la adopción. El mensaje indica la ruta de los datos adoptados, el
  comando `printf '%s\n' 'NOMBRE' > 'RUTA_CONFIG'` y qué temporales pueden borrarse.
- Si la adopción y la configuración se completaron pero no se puede borrar el marcador `ADOPTING` o el
  temporal, `wl init` sale con rc=1 sin mensaje de éxito: los datos ya están adoptados y el mensaje indica
  qué directorio temporal puede borrarse. Ese temporal ya no contiene `clone/<equipo>`, así que no bloquea un nuevo `wl init`.

**Límites:** sin locking ni garantía de concurrencia: una escritura concurrente durante `wl init` se
detecta, como mucho, por el fallo del rollback descrito arriba. No hay reconciliación ni merge de logs.
`/mnt/c` no se ha evaluado.

## `wl sync` con remoto inalcanzable

La sección 19 del test simula un fallo inmediato de transporte (URL `file://` a una ruta inexistente):
`wl sync` sale con rc=2, stdout vacío, stderr `wl: push falló; las entradas están a salvo en local`,
el commit local se conserva y, al restaurar el remoto, `wl sync` devuelve 0. No acredita comportamiento
con timeouts, DNS, red caída, autenticación ni WSL2.
