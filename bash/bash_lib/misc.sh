# buscar en historial con fzf y (opcionalmente) ejecutar
# - Si no hay historial disponible, aborta limpio.
# - Dedup: colapsa comandos idénticos para no ver 40 veces el mismo curl.
# - Preview para ver el comando completo.
# - Ejecuta en SUBSHELL ( ) para no ensuciar sesión actual a no ser que confirmes --live.
#
# Uso:
#   fhist           -> busca, pregunta, ejecuta en subshell si dices "y"
#   fhist --live    -> ejecuta en shell (eval) si dices "y"

fhist() {
  _req fzf || return 1

  local mode="subshell"
  if [ "$1" = "--live" ]; then
    mode="live"
    shift
  fi

  local hist
  hist="$(HISTTIMEFORMAT= history 2>/dev/null | sed 's/^ *[0-9]\+ *//')" || true
  if [ -z "$hist" ]; then
    printf 'No hay historial disponible en estra sesión.\n' >&2
    return 1
  fi

  local cmd
  cmd="$(
    prinf '%s\n' "$hist" |
      awk '!seen[$0]++' |
      fzf --height 40% \
        --layout=reverse \
        --tac \
        --prompt='📜 hist > ' \
        --preview='echo {}' \
        --preview-window=down,3
  )" || return 0

  [ -z "$cmd" ] && return 0

  printf 'Comando seleccionado:\n%s\n' "$cmd" >&2
  printf '¿Ejecutar ahora? [y/N] ' >&2
  read -r ans
  [ "$ans" = "y" ] || {
    printf '%s\n' "$cmd"
    return 0
  }

  if [ "$mode" = "live" ]; then
    eval "$cmd"
  else
    (eval "$cmd")
  fi
}

# lista/añade tareas rápidas en ~/.todo.cli.txt
# - Evita crear el archivo con permisos abiertos. Lo fuerza a 600.
todo() {
  local file="$HOME/.todo.cli.txt"

  if [ ! -f "$file" ]; then
    : >"$file"
    chmod 600 "$file" 2>/dev/null || true
  fi

  if [ $# -eq 0 ]; then
    nl -ba "$file" 2>/dev/null || printf '(lista vacia)\n'
    return 0
  fi

  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M')" "$*" >>"$file"
  printf "Añadido a TODO: %s\n" "$*" >&2
}

# Mide cuanto tiempo tarda en ejecutarse un comandos
# # - Ejecuta el comando en SUBSHELL para no alterar la sesión.
bench() {
  _req awk || return 1

  if [ $# -eq 0 ]; then
    printf 'Uso: bench <comando ...>\n' >&2
    return 1
  fi

  _now_ms() {
    if date +%s%3N >/dev/null 2>&1; then
      date +%s%3N
    else
      if date +%s%N >/dev/null 2>&1; then
        awk -v ns="$(date +%s%N)" 'BEGIN{print int ns/1000000)}'
      else
        awk -v s="$(date +%s)" 'BEGIN{print s*1000}'
      fi
    fi
  }

  local start end delta secs
  start="$(now_ms)"
  ("$@")
  end="$(_now_ms)"

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
#
# - asume archivos tipo .env.staging, .env.local, etc.
# - Valida que exista .env.* antes de tocar nada.
# - Hace backup con permisos 600.
# - Fuerza permisos 600 en el .env final.
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
      local bak="$base.bak.$(date +%s)"
      cp "$base" "$bak"
      chmod 600 "$bak" 2>/dev/null || true
      printf '(bakup en %s)\n' "$bak" >&2
    fi

    cp "$src" "$base"
    chmod 600 "$base" 2>/dev/null || true
    printf '✔ %s activado -> %s\n' "$src" "$base" >&2
    return 0
  fi

  printf 'Uso:\n' >&2
  printf '  envswap list           # ver entornos disponibles (.env.*)\n' >&2
  printf '  envswap use staging    # copia .env.staging -> .env (con backup y chmod 600)\n' >&2
  return 1
}

# editar y re-ejecutar el último comando del history
#
# - Usa penúltima entrada del history (evita capturar el propio 'r').
# - Crea tmp 600.
# - Después de ejecutar, borra el tmp.
# - Pregunta antes de ejecutar con `source`
r() {
  _req "${EDITOR:-nvim}" >/dev/null 2>&1 || true

  local tmp last
  tmp="$(mktemp)"
  chmod 600 "$tmp" 2>/dev/null || true

  last="$(HISTTIMEFORMAT= history 2>/dev/null |
    sed 's/^ *[0-9]\+ *//' |
    tail -n 2 | head -n 1)"

  printf '%s\n' "$last" >"$tmp"
  "${VISUAL:-${EDITOR:-nvim}}" "$tmp"

  printf 'Esto se va a ejectuar en la shell actual. ¿Ejecutar? [y/N] ' >&2
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
  _req awk || return 1
  if command -v ss >/dev/null 2>&1; then
    ss -tulpen 2>/dev/null |
      awk 'NR==1 {printf "%-6s %-30s %-20s %-15s\n,"Proto","LocalAddress:Port","PID/Program","User"; next}
             NR>1 {
               proto=$1; laddr=$5; user=$6; prog=$7;
               printf "%-6s %-30s %-20 %-15s\n", proto,laddr,prog,user
             }'
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN
  else
    printf 'Necesito ss o lsof.\n' >&2
    return 1
  fi
}

# Monitoreo rapido de CPU/MEM de procesos que me importan
# Prioriza por CPU alta
topme() {
  _req awk || return 1
  ps -eo pid,ppid,user,%cpu,%mem,etime,cmd --sort=-%cpu |
    awk 'NR==1 || /php|fpm|nginx|mysql|maria|docker|composer|artisan|symfony|node|redis|postg|psql/'
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
