# misc.sh - utilidades varias

# buscar en historial con fzf y (opcionalmente) ejecutar
# - Si no hay historial disponible, aborta limpio.
# - Dedup: colapsa comandos idénticos para no ver 40 veces el mismo curl.
# - Preview para ver el comando completo.
# - Ejecuta en SUBSHELL ( ) para no ensuciar sesión actual a no ser que confirmes --live.
#
# Uso:
#   fhist           -> busca, pregunta, ejecuta en subshell si dices "y"
#   fhist --live    -> ejecuta en shell (eval) si dices "y"
# @cmd fhist  Buscar en history con fzf y ejecutar (subshell o live)
fhist() {
  _req fzf || return 1

  local mode="subshell"
  if [ "$1" = "--live" ]; then
    mode="live"
    shift
  fi

  local hist
  hist="$(HISTTIMEFORMAT='' history 2>/dev/null | sed 's/^ *[0-9]\+ *//')" || true
  if [ -z "$hist" ]; then
    printf 'No hay historial disponible en esta sesión.\n' >&2
    return 1
  fi

  hist="$(
    printf '%s\n' "$hist" |
      tac | awk '!seen[$0]++' | tac |
      grep -Ev '^(ls|cd|pwd|historyi|fhist|redo|r)($| )' || true
  )"

  if [ -z "$hist" ]; then
    printf 'No hay comandos interesantes tras el filtrado.\n' >&2
    return 1
  fi

  local cmd
  cmd="$(
    printf '%s\n' "$hist" |
      fzf --tac \
        --prompt='📜 hist > ' \
        --preview='echo {}' \
        --preview-window=down,3
  )" || return 0

  [ -z "$cmd" ] && return 0

  printf 'Comando seleccionado:\n%s\n' "$cmd" >&2
  if ! _confirm '¿Ejecutar ahora? [y/N] '; then
    printf '%s\n' "$cmd"
    return 0
  fi

  case "$mode" in
  live) eval "$cmd" ;;
  subshell) (eval "$cmd") ;;
  esac
}

# lista/añade tareas rápidas en ~/.todo.cli.txt
# - Evita crear el archivo con permisos abiertos. Lo fuerza a 600.
# @cmd todo   Añadir entrada a un TODO plano con timestamp
todo() {
  local file="${TODO_FILE:-$HOME/.todo.cli.txt}"
  mkdir -p -- "$(dirname "$file")" 2>/dev/null || true

  if [ ! -f "$file" ]; then
    : >"$file"
    chmod 600 "$file" 2>/dev/null || true
  fi

  if [ $# -eq 0 ]; then
    nl -ba "$file" 2>/dev/null || printf 'Lista vacía.\n'
    return 0
  fi

  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M')" "$*" >>"$file"
  printf "Añadido a TODO: %s\n" "$*" >&2
}

# Mide cuanto tiempo tarda en ejecutarse un comandos
# # - Ejecuta el comando en SUBSHELL para no alterar la sesión.
# @cmd bench  Medir el tiempo de ejecución de un comando (ms/segundos)
bench() {
  _req awk || return 1

  if [ $# -eq 0 ]; then
    printf 'Uso: bench <comando ...>\n' >&2
    return 1
  fi

  _now_ms() {
    if date +%s%3N >/dev/null 2>&1; then
      date +%s%3N
      return
    fi

    date +%s | awk '{ print $1 * 1000 }'
  }

  local start end delta
  start="$(_now_ms)"
  ("$@")
  local status=$?
  end="$(_now_ms)"

  delta=$((end - start))

  if command -v bc >/dev/null 2>&1; then
    printf 'Tiempo: %s ms (~%.3f s)\n' "$delta" \
      "$(printf '%s / 1000' "$delta" | bc -l)"
  else
    printf 'Tiempo: %s ms (~%s s)\n' "$delta" "$((delta / 1000))"
  fi

  return "$status"
}

# Cambia entre distintos .env de forma segura
# uso:
#   envswap list
#   envswap use staging
#
# - asume archivos tipo .env.staging, .env.local, etc.
# - Valida que exista .env.* antes de tocar nada.
# - Hace backup con permisos 600.
# - Fuerza permisos 600 en el .env final.
# @cmd envswap  Gestionar .env.<nombre> -> .env con backup
envswap() {
  local base=".env"
  local cmd="${1:-}"
  local name="${2:-}"

  if [ "$cmd" = "list" ]; then
    local f
    local -a envs=()

    for f in .env.*; do
      # si no hay coincidencias, el glob se queda literal
      [ -e "$f" ] || continue
      envs+=("${f#.env.}")
    done

    # Nada que listar
    ((${#envs[@]} == 0)) && return 0

    # Ordenado
    printf '%s\n' "${envs[@]}" | sort
    return 0
  fi

  if [ "$cmd" = "use" ] && [ -n "$name" ]; then
    local src=".env.$name"

    if [ ! -f "$src" ]; then
      printf 'No existe %s\n' "$src" >&2
      return 1
    fi

    if [ -f "$base" ]; then
      local bak
      bak="$base.bak.$(date +%s)"
      cp -- "$base" "$bak"
      chmod 600 "$bak" 2>/dev/null || true
      printf '(backup en %s)\n' "$bak" >&2
    fi

    cp -- "$src" "$base"
    chmod 600 "$base" 2>/dev/null || true
    printf '✔ %s activado -> %s\n' "$src" "$base" >&2
    return 0
  fi

  printf 'Uso:\n' >&2
  printf '  envswap list           # ver entornos disponibles (.env.*)\n' >&2
  printf '  envswap use staging    # copia .env.staging -> .env (con backup y chmod 600)\n' >&2
  return 1
}

# Quien escucha en que puerto
# @cmd ports  Ver puertos en escucha (ss/netstat simplificado)
ports() {
  _req awk || return 1

  if command -v ss >/dev/null 2>&1; then
    ss -tulpen 2>/dev/null |
      awk '
        NR==1 {
          printf "%-6s %-30s %-24s %-10s\n", "Proto","Local","PID/Program","User"
          next
        }
        {
          proto=$1;
          laddr=$5;
          user=$6;
          prog=$7;
          printf "%-6s %-30s %-24s %-10s\n", proto, laddr, prog, user
        }
      '
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tulpen 2>/dev/null |
      awk '
        NR==1 {
          printf "%-6s %-30s %-24s %-10s\n", "Proto","Local","PID/Program","User"
          next
        }
        {
          proto=$1;
          laddr=$5;
          user=$6;
          prog=$7;
          printf "%-6s %-30s %-24s %-10s\n", proto, laddr, prog, user
        }
      '
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN
  else
    printf 'Necesito ss, netstat o lsof.\n' >&2
    return 1
  fi
}

# editar y re-ejecutar el último comando del history
#
# - Usa penúltima entrada del history (evita capturar el propio 'r').
# - Crea tmp 600.
# - Después de ejecutar, borra el tmp.
# - Pregunta antes de ejecutar con `source`
# @cmd r  Editar y re-ejecutar el penúltimo comando del history
r() {
  # Nos aseguramos que hay editor
  if ! _req "${VISUAL:-${EDITOR:-nvim}}"; then
    printf 'No encuentro editor (VISUAL/EDITOR/nvim).\n' >&2
    return 1
  fi

  local tmp last
  tmp="$(mktemp)"
  chmod 600 "$tmp" 2>/dev/null || true

  last="$(
    HISTTIMEFORMAT='' history 2>/dev/null |
      sed 's/^ *[0-9]\+ *//' |
      tail -n 2 | head -n 1
  )"

  if [ -z "$last" ]; then
    printf 'No puedo recuperar el último comando.\n' >&2
    rm -f -- "$tmp"
    return 1
  fi

  printf '%s\n' "$last" >"$tmp"
  "${VISUAL:-${EDITOR:-nvim}}" "$tmp"

  printf 'Esto se va a ejecutar en la shell actual.\n' >&2
  if ! _confirm '¿Ejecutar? [y/N] '; then
    rm -f -- "$tmp"
    return 0
  fi

  # shellcheck disable=SC1090
  . "$tmp"
  rm -f -- "$tmp"
}

# Añade un temporizador interactivo simple
# @cmd tt   Temporizador manual (ENTER para parar)
tt() {
  local start end delta
  start=$(date +%s)
  printf 'Timer iniciado. Pulsa ENTER al terminar...\n' >&2
  read -r _
  end=$(date +%s)
  delta=$((end - start))
  printf '%s segundos (%s min)\n' "$delta" "$((delta / 60))"
}

# Monitoreo rapido de CPU/MEM de procesos que me importan
# Prioriza por CPU alta
# @cmd topme  Procesos relevantes (stack dev) ordenados por consumo
topme() {
  _req awk ps || return 1
  ps -eo pid,ppid,user,%cpu,%mem,etime,cmd --sort=-%cpu |
    awk 'NR==1 || /php|fpm|nginx|mysql|maria|docker|composer|artisan|symfony|node|redis|postg|psql/'
}

# Wrapper de Yazi, cd al salir
# @cmd y  Wrapper de yazi que hace cd al salir
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"

  if ! IFS= read -r -d '' cwd <"$tmp"; then
    cwd="$(cat -- "$tmp")"
  fi

  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || printf 'y: no pude hacer cd a "%s"\n' "$cwd" >&2
  fi

  rm -f -- "$tmp"
}

# @cmd dev  Crear/adjuntar sesión tmux ligada al proyecto actual
dev() {
  _req tmux || return 1

  local dest name

  if [ -n "${1:-}" ]; then
    if [ -d "$1" ]; then
      dest="$(cd -- "$1" && pwd)"
    else
      printf 'Directorio no existe: %s\n' "$1" >&2
      return 1
    fi
  else
    if git-rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      dest="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    else
      if ! command -v proj >/dev/null 2>&1; then
        printf 'proj no esta definido. No puedo seleccionar proyecto.\n' >&2
        return 1
      fi
      proj || return 1
      dest="$PWD"
    fi
  fi

  if [ -z "$dest" ] || [ ! -d "$dest" ]; then
    printf 'Destino inválido: %s\n' "${dest:-<vacío>}" >&2
    return 1
  fi

  name="$(basename "$dest")"

  if tmux has-session -t "$name" 2>/dev/null; then
    if [ -n "${TMUX:-}" ]; then
      tmux switch-client -t "$name"
    else
      tmux attach -t "$name"
    fi
    return 0
  fi

  if [ -n "${TMUX:-}" ]; then
    tmux new-session -ds "$name" -c "$dest"
    tmux switch-client -t "$name"
  else
    tmux new-session -s "$name" -c "$dest"
  fi
}

# @cmd tswitch  Cambiar a otra sesión de tmux y cerrar la actual (fzf)
tswitch() {
  _req tmux fzf || return 1
  [ -z "${TMUX:-}" ] && {
    printf 'tswitch: no estás dentro de tmux.\n' >&2
    return 1
  }

  local current target

  current="$(tmux display-message -p '#S')"

  target="$(
    tmux list-sessions -F '#S' |
      grep -v "^${current}$" |
      fzf --prompt=' tmux session > '
  )" || return 0

  [ -z "$target" ] && return 0

  # Cambiamos el Destino
  tmux switch-client -t "$target"

  # Matamos la sesión anteriorf sólo si sigue existiendo
  if tmux has-session -t "$current" 2>/dev/null; then
    tmux kill-session -t "$current"
  fi
}
