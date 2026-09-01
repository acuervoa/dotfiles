# Baseline de rendimiento Bash — 2026-09-01

## Alcance

Medición de sólo lectura posterior a la auditoría de comandos. No se
aplicaron cambios de carga diferida ni se modificó ninguna configuración.
La ejecución usa `script` para proporcionar un pseudo-TTY y
`TERM=xterm-256color`. Cada cifra son cinco ejecuciones; se informa la
mediana. El coste de cada componente aislado incluye el coste fijo de crear
una Bash interactiva y, por tanto, no debe sumarse como si fuera aditivo.

## Arranque completo

| Shell | Mediciones (s) | Mediana |
| --- | --- | ---: |
| No-login: `bash -ic exit` | 0.479, 0.310, 0.335, 0.290, 0.284 | **0.310** |
| Login: `bash -lic exit` | 0.672, 0.600, 0.624, 0.627, 0.879 | **0.627** |

Presupuesto provisional para comparar cambios: mantener la mediana no-login
por debajo de 0.35 s y la login por debajo de 0.70 s hasta disponer de una
medición directa dentro de Kitty.

## Componentes aislados

| Componente | Mediana (s) | Lectura |
| --- | ---: | --- |
| `.profile` | 0.024 | entorno general y PATH |
| `.bash_profile` | 0.281 | dispatcher login; incluye `.profile` y `.bashrc` |
| `.bashrc` | 0.256 | configuración interactiva completa |
| bash-completion | 0.050 | carga independiente |
| Atuin | 0.059 | `atuin init bash --disable-up-arrow` |
| ble.sh | 0.024 | `ble.sh --noattach` |
| zoxide | 0.031 | `zoxide init bash` |
| direnv | 0.031 | `direnv hook bash` |
| Starship | 0.056 | `starship init bash` |
| mise | 0.125 | `mise activate bash` |
| fnm | 0.036 | `fnm env --use-on-cd --shell=bash` |
| `.bashrc_local` | 0.027 | sólo se midió su carga; no se reprodujo su contenido |

El mayor componente individual observado es `mise activate bash`, seguido de
Atuin, Starship y bash-completion. La cifra de `.bashrc` ya contiene varias
de estas cargas y no prueba por sí sola que una optimización concreta sea
beneficiosa.

## PATH y duplicados

La sesión login produjo un PATH efectivo sin entradas duplicadas. El orden
observado mantiene delante:

```text
$HOME/.local/bin
$HOME/bin
$HOME/.bun/bin
$HOME/.opencode/bin
$HOME/.local/share/composer/vendor/bin
```

Después aparecen Codex temporal, fnm, Juliaup, Cargo y las rutas del sistema.
No se detecta un problema de duplicación que justifique cambios en esta
iteración.

## Limitaciones

- `script` proporciona TTY, pero no es una ventana Kitty real bajo i3/tmux;
  debe repetirse allí antes de fijar un presupuesto definitivo.
- No se modificó ni se mostró el contenido de `.bashrc_local`; su cifra es
  únicamente tiempo de carga.
- Sí se midió la primera orden, pero no la latencia de interacción de
  tecleo/edición.
- Tampoco se hizo una ventana Kitty real.
- No se hizo carga diferida: este documento es baseline, no una propuesta de
  implementación.

## Siguiente decisión

Antes de tocar `.bashrc`, repetir el mismo protocolo dentro de Kitty, con y
sin tmux, y medir la primera orden. Sólo los componentes cuyo coste sea
relevante en esa medición deben considerarse para carga diferida.

## Seguimiento — 2026-09-01

### Contexto confirmado

La ejecución confirmó un entorno gráfico activo.

La medición fue orientativa y se ejecutó con un pseudo-TTY, no desde una
ventana Kitty real.

### Método y condiciones

Para el arranque no-login se hicieron cinco ejecuciones de:

```text
script -qefc "env TERM=xterm-256color bash -i -c ':'" /dev/null
```

Para el arranque login se usó:

```text
script -qefc "env TERM=xterm-256color bash --login -i -c ':'" /dev/null
```

Se tomó el tiempo wall-clock con `date +%s%N` inmediatamente antes y después
de cada ejecución, y se calculó la mediana de los cinco valores. Para la
primera orden se usó el mismo método con:

```text
script -qefc "env TERM=xterm-256color bash -i -c 'command -v true >/dev/null'" /dev/null
```

Cada pareja partió del mismo proceso padre y del mismo entorno heredado;
`TERM` se fijó explícitamente. Sólo la variante A/B añade
`MISE_INITIALIZED=1 FNM_INITIALIZED=1`. No se leyeron archivos privados ni se
escribió el repositorio.

Reproducción compacta: el bloque crea un `HOME` temporal y un `.bashrc`
sintácticamente válido, basado en `.bashrc` pero omitiendo estructuralmente el
bloque de carga de `.bashrc_local`; no lee el historial ni `.bashrc_local` y no
escribe el repositorio. Así reproduce el protocolo sin datos privados, aunque
no es una copia exacta del entorno real.

```bash
#!/usr/bin/env bash
set -eu
source_home=${HOME:?}
tmp_home=$(mktemp -d /tmp/bash-performance-home.XXXXXX)
tmp="$tmp_home/output"
trap 'rm -rf -- "$tmp_home"' EXIT

mkdir -p "$tmp_home"/{.config/atuin,.data/atuin,.cache/atuin}
awk '
  /^# Cargar configuraciones locales si existen[[:space:]]*$/ { skip=1; next }
  skip && /^fi[[:space:]]*$/ { skip=0; next }
  !skip { print }
' "$source_home/.bashrc" >"$tmp_home/.bashrc"
bash -n "$tmp_home/.bashrc"
{
  printf '%s\n' 'export PROFILE_LOADED=yes'
  cat "$source_home/.profile"
} >"$tmp_home/.profile"
printf '%s\n' \
  '[ -f "$HOME/.profile" ] && . "$HOME/.profile"' \
  '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"' >"$tmp_home/.bash_profile"

measure() { # etiqueta login(0|1) primera_orden(0|1) entorno(inherited|clean|ab)
  local label=$1 login=$2 first=$3 variant=$4 cmd prefix start end median
  local -a times=()
  if (( first )); then
    cmd="bash -i -c 'command -v true >/dev/null'"
  elif (( login )); then
    cmd="bash --login -i -c ':'"
  else
    cmd="bash -i -c ':'"
  fi
  prefix='env'
  case $variant in
    inherited) ;;
    clean) prefix="$prefix -u TMUX -u KITTY_WINDOW_ID" ;;
    ab) prefix="$prefix MISE_INITIALIZED=1 FNM_INITIALIZED=1" ;;
    *) return 2 ;;
  esac
  prefix="$prefix HOME=$tmp_home XDG_CONFIG_HOME=$tmp_home/.config XDG_DATA_HOME=$tmp_home/.data XDG_CACHE_HOME=$tmp_home/.cache ATUIN_CONFIG_DIR=$tmp_home/.config/atuin ATUIN_DATA_DIR=$tmp_home/.data/atuin ATUIN_CACHE_DIR=$tmp_home/.cache/atuin HISTFILE=$tmp_home/.bash_history PROFILE_LOADED=yes TERM=xterm-256color"
  for _ in 1 2 3 4 5; do
    start=$(date +%s%N)
    script -qefc "$prefix $cmd" /dev/null >"$tmp" 2>&1
    end=$(date +%s%N)
    times+=("$((end - start))")
  done
  printf '%s: %s\n' "$label" "${times[*]}"
  median=$(printf '%s\n' "${times[@]}" | sort -n | awk 'NR == 3 { print; exit }')
  printf '  mediana (ordenando los cinco valores): %s ns\n' "$median"
}

measure no-login 0 0 inherited
measure login 1 0 inherited
measure primera-orden 0 1 inherited
measure no-login-sin-contexto 0 0 clean
measure login-sin-contexto 1 0 clean
measure primera-orden-sin-contexto 0 1 clean
measure login-ab 1 0 ab
```

### Arranque orientativo desde pseudo-TTY

Las cifras se obtuvieron con o sin el entorno heredado y no son mediciones
dentro de una ventana Kitty real. `n=5` es una muestra orientativa; el
presupuesto se evalúa sobre la mediana y las cifras no se suman por
componente.

| Caso medido desde pseudo-TTY | Mediciones (s) | Mediana (s) |
| --- | --- | ---: |
| Con entorno heredado, no-login | 0.313, 0.302, 0.277, 0.279, 0.324 | **0.302** |
| Sin entorno heredado, no-login | 0.279, 0.314, 0.399, 0.279, 0.272 | **0.279** |
| Con entorno heredado, login | 0.601, 0.584, 0.567, 0.692, 0.658 | **0.601** |
| Sin entorno heredado, login | 0.565, 0.640, 0.586, 0.627, 0.558 | **0.586** |
| Primera orden, con entorno heredado | 0.272, 0.287, 0.354, 0.323, 0.361 | **0.323** |
| Primera orden, sin entorno heredado | 0.294, 0.263, 0.289, 0.263, 0.314 | **0.289** |

### A/B de login desde pseudo-TTY

Ambas variantes usaron el mismo protocolo: cinco ejecuciones, pseudo-TTY y
entorno heredado. Sólo cambia la preasignación de
`MISE_INITIALIZED=1 FNM_INITIALIZED=1`.

| Variante | Mediciones (s) | Mediana (s) |
| --- | --- | ---: |
| Baseline | 0.663, 0.578, 0.594, 0.580, 0.582 | **0.582** |
| Saltando mise/fnm (`MISE_INITIALIZED=1 FNM_INITIALIZED=1`) | 0.623, 0.576, 0.618, 0.624, 0.597 | **0.618** |

### Interpretación y próxima evidencia

Las medianas quedan dentro del presupuesto provisional: mediana no-login
inferior a 0.35 s y mediana login inferior a 0.70 s. La medición individual
de 0.399 s es una excedencia puntual del umbral, no de la mediana, por lo que
es necesario repetir la prueba. El A/B no muestra mejora al saltar mise/fnm:
mediana de 0.582 s en el baseline frente a 0.618 s al saltar mise/fnm.
Por tanto, no se justifica introducir carga diferida ni cambiar la
configuración con esta evidencia.

La próxima evidencia necesaria es repetir la medición desde un prompt Bash
visible en Kitty y medir la interacción real.
