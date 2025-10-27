# Buscar en el historial con fzf y (opcionalmente) ejecutar
# - Pide confirmación ANTES de eval

fhist() {
  _req fzf || return 1

  local cmd
  cmd="$(
    HISTTIMEFORMAT= history |
      sed 's/^ *[0-9]\+ *//' |
      fzf --height 40% \
        --layout=reverse \
        --tac \
        --prompt='📜 hist > '
  )" || return 0

  [ -z "$cmd" ] && return 0

  printf 'Comando seleccionado:\n%s\n' "$cmd" >&2
  printf '¿Ejecutar ahora? [y/N] ' >&2
  read -r ans
  if [ "$ans" = "y" ]; then
    eval "$cmd"
  else
    printf '%s\n' "$cmd"
  fi
}

# Agregar una líne rápida a lista de tareas
todo() {
  local file="$HOME/.todo.cli.txt"

  if [ $# -eq 0 ]; then
    nl -ba "$file" 2>/dev/null || printf '(lista vacia)\n'
    return 0
  fi

  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M')" "$*" >>"$file"
  printf "Añadido a TODO: %s\n" "$*" >&2
}

# Mide cuanto tiempo tarda en ejecutarse un comando
bench() {
  if [ $# -eq 0 ]; then
    printf 'Uso: bench <comando ...>\n' >&2
    return 1
  fi

  local start end delta secs
  start=$(date +%s%3N) # ms en GNU date
  "$@"
  end=$(date +%s%3N)
  delta=$((end - start))

  if command -v bc >/dev/null 2>&1; then
    secs="$(echo "$delta / 1000" | bc -l)"
  else
    secs="$(awk -v d="$delta" 'BEGIN{ printf "%.3f", d/1000 }')"
  fi
  printf "⏱  %s ms (~%s s)\n" "$delta" "$secs"
}

# Cambia entre distintos .env de forma segura
# uso:
#   envswap list
#   envswap use staging
# asume archivos tipo .env.staging, .env.local, etc.
envswap() {

  local base=".env"
  local cmd="$1"
  local name="$2"

  if [ "$cmd" = "list" ]; then
    ls -1 .env.* 2>/dev/null |
      sed 's/^\.env\.//' |
      sort
    return 0
  fi

  if [ "$cmd" = "use" ] && [ -n "$name" ]; then
    local src=".env.$name"
    if [ ! -f "$src" ]; then
      printf 'No existe %s\n' "$src" >&2
      return 1
    fi

    if [ -f "$base" ]; then
      cp "$base" "$base.bak.$(date +%s)"
    fi

    cp "$src" "$base"
    printf '✔ %s activado -> %s\n' "$src" "$base" >&2
    return 0
  fi

  printf 'Uso:\n' >&2
  printf '  envswap list           # ver entornos disponibles (.env.*)\n' >&2
  printf '  envswap use staging    # copia .env.staging -> .env (con backup)\n' >&2
  return 1
}

# "Hazlo otra vez"
r() {
  local tmp last
  tmp="$(mktemp)"

  last="$(HISTTIMEFORMAT= history | sed 's/^ *[0-9]\+ *//' | tail -n 2 | head -n 1)"
  printf '%s\n' "$last" >"$tmp"
  "${EDITOR:-nvim}" "$tmp"
  printf 'Ejecutar?\n' >&2
  read -r ans
  if [ "$ans" = "y" ]; then
    . "$tmp"
  else
    cat "$tmp"
  fi
  rm -f "$tmp"
}
# Quien escucha en que puerto
ports() {
  if command -v ss >/dev/null 2>&1; then
    ss -tulpen 2>/dev/null |
      sed '1,1!s/^/ /' |
      awk '{print $1, $5, $7, $9}' |
      column -t
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN
  else
    printf 'Necesito ss o lsof.\n' >&2
    return 1
  fi
}

# Monitoreo rapido de CPU/MEM de procesos
topme() {
  ps -eo pid,ppid,user,%cpu,%mem,etime,cmd --sort=-%cpu |
    awk 'NR==1 || /php|fpm|nginx|mysql|docker|composer|artisan|symfony/'
}

# Añade un temporizador interactivo simple
tt() {
  local start end delta
  start=$(date +%s)
  printf 'Timer iniciado. Pulsa ENTER al terminar...\n' >&2
  read -r _
  end=$(date +%s)
  delta=$((end - start))
  printf '%s segundos (%s min)\n' "$delta" "$((delta / 60))"
}
