#!/usr/bin/env bash
# core.sh — funciones útiles no cubiertas por aliases

# @cmd _req Comprobar que existen todos los binarios requeridos
_req() {
  local missing=0 c
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      printf 'Falta comando requerido: %s\n' "$c" >&2
      missing=1
    fi
  done
  return $missing
}

# Función de confirmación
# @cmd _confirm Preguntar al usuario antes de ejecutar acciones peligrosas
_confirm() {
  local msg="${1:-¿Continuar? [y/N] }"
  local ans
  printf '%s' "$msg" >&2
  read -r ans
  [ "$ans" = "y" ]
}

# Abre archivo en el editor preferido.
# Respeta $VISUAL, luego $EDITOR. Fallback a nvim/vim/nano.
# Si se pasa número de línea y el editor soporta "+<line>", lo usa.
# @cmd _edit_at  Abrir fichero en $EDITOR en una linea concreta (si se facilita)
_edit_at() {
  local file="$1" line="$2" editor

  [ -z "$file" ] && {
    printf 'No hay fichero que abrir.\n' >&2
    return 1
  }

  [ ! -f "$file" ] && {
    printf 'El fichero no existe: %s\n' "$file" >&2
    return 1
  }

  editor="${VISUAL:-${EDITOR:-}}"
  if [ -z "$editor" ]; then
    if command -v nvim >/dev/null 2>&1; then
      editor="nvim"
    elif command -v vim >/dev/null 2>&1; then
      editor="vim"
    elif command -v nano >/dev/null 2>&1; then
      editor="nano"
    else
      printf 'No hay editor configurado (EDITOR/VISUAL).\n' >&2
      return 1
    fi
  fi

  if [ -n "$line" ]; then
    case "$editor" in
    *nvim | *vim)
      "$editor" "+${line}" "$file"
      ;;
    *code)
      "$editor" -g "${file}:${line}"
      ;;
    *)
      "$editor" "$file"
      ;;
    esac
  else
    "$editor" "$file"
  fi
}

# Papelera en vez de rm directo
# @cmd trash  Enviar archivos al contenedor (trash-cli)
trash() {
  _req trash-put || {
    printf 'Necesito trash-put (paquete trash-cli)\n' >&2
    return 1
  }

  if [ "$#" -eq 0 ]; then
    printf 'Uso: trash <archivo...>\n' >&2
    return 1
  fi

  trash-put -- "$@"
}

# Matar procesos con confirmación
# - No mata ciegamente con -9
# - Evita matar PID 1, tu propio shell
# - Envia SIGTERM primero, luego opcional SIGKILL
# - Pide confirmación
# @cmd fkill  Elegir procesos con fzf y enviar SIGTERM/SIGKILL
fkill() {
  _req fzf ps awk kill || return 1

  local sel
  sel="$(
    ps -eo pid,user,stat,%cpu,%mem,cmd --sort=-%cpu |
      awk 'NR>1' |
      fzf --ansi --multi \
        --prompt=' kill > ' \
        --header='SPACE para marcar, ENTER para confirmar)' \
        --preview='echo PID:{1}; ps -p {1} -o pid,ppid,user,stat,%cpu,%mem,etime,cmd' \
        --preview-window=down,50%
  )" || return 0

  local pids=() line pid

  [ -z "$sel" ] && return 0

  while IFS= read -r line; do
    pid="$(printf '%s\n' "$line" | awk '{print $1}')"
    [ "$pid" = "1" ] || [ "$pid" = "$$" ] || pids+=("$pid")
  done <<<"$sel"

  [ "${#pids[@]}" -eq 0 ] && {
    printf 'Nada que matar.\n' >&2
    return 0
  }

  printf 'Vas a enviar SIGTERM a: %s\n' "${pids[*]}" >&2
  _confirm || return 0

  printf 'killing proceso: %s\n' "${pids[@]}"
  kill -- "${pids[@]}" 2>/dev/null

  sleep 0.3
  local still_up=()
  for pid in "${pids[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      still_up+=("$pid")
    fi
  done

  if [ "${#still_up[@]}" -gt 0 ]; then
    printf 'Estos siguen vivos: %s\n' "${still_up[*]}" >&2
    _confirm "¿Forzar con SIGKILL (-9)? [y/N] " || return 0
    kill -9 -- "${still_up[@]}" 2>/dev/null
  fi
}

_rfg_preview() {
  local file="$1" line="$2"

  if command -v bat >/dev/null 2>&1; then
    bat --style=numbers --color=always --highlight-line="$line" "$file"
  else
    nl -ba "$file" | sed -n "$((line - 5)),$((line + 5))p"
  fi
}
# Buscar en el repo con ripgrep + abrir en el editor
# - Maneja patrón vacio
# - Soporta múltiples selecciones
# - Respeta espacios en rutas.
# - Abre el editor saltando a la linea exacta
# - Vista previa recortada centrada en la linea del match
# @cmd rgf  Buscar con ripgrep + fzf y abrir resultados en $EDITOR
rgf() {
  _req rg fzf bat awk || return 1

  if [ $# -eq 0 ]; then
    printf 'Uso: rgf <patrón de búsqueda>\n' >&2
    return 1
  fi

  local results
  results="$(
    rg --vimgrep --hidden --glob '!.git' -- "$@" 2>/dev/null |
      fzf --multi \
        --prompt=' rg > ' \
        --delimiter=':' \
        --nth=4.. \
        --preview='_rfg_preview {1} {2}' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$results" ] && return 0

  local fpath lnum line
  while IFS= read -r line; do
    fpath="$(printf '%s\n' "$line" | awk -F: '{print $1}')"
    lnum="$(printf '%s\n' "$line" | awk -F: '{print $2}')"

    [ -n "$fpath" ] && [ -f "$fpath" ] && _edit_at "$fpath" "$lnum"
  done <<<"$results"
}

# Lanzar/adjuntar a una sesión tmux por nombre (default: main)
# @cmd t  Crear/adjuntar sesión tmux
t() {
  _req tmux || return 1

  if [ "${1:-}" = "net-if" ]; then
    shift
    local value="$*"

    if [ $# -eq 0 ]; then
      tmux set -g @net_if ""
      printf 'Limpiado @net_if; la pastilla de red autodetectará interfaces activas.\n' >&2
    else
      tmux set -g @net_if "$value"
      printf 'Establecido tmux @net_if -> %s\n' "$value" >&2
    fi

    return 0
  fi

  local name="${1:-main}"

  if tmux has-session -t "$name" 2>/dev/null; then
    tmux attach -t "$name"
  else
    tmux new -s "$name"
  fi
}

# volver a ejecutar el último comando interactivo
# - Reejecuta el comando anterior al `redo` leyendo el history.
# - Útil para: "me dio error, ejecuto 'redo' directamente".
# - Limitación: si lo último en el history es literalmente 'redo', entraría bucle.
#   Lo evitamos leyendo el penúltimo comando de history.
# @cmd redo   Reejecutar el penúltimo comando del history
redo() {
  local last
  last="$(
    HISTTIMEFORMAT='' history 2>/dev/null |
      sed 's/^ *[0-9]\+ *//' |
      tail -n 2 | head -n 1
  )"

  if [ -z "$last" ]; then
    printf 'No puedo recuperar el último comando.\n' >&2
    return 1
  fi

  printf 'Reejecutando; %s\n' "$last" >&2
  eval "$last"
}

# @cmd dothelp  Listar funciones del bash_lib con descripción
dothelp() {
  local dir="${1:-${BASH_LIB_DIR:-$HOME/.bash_lib}}"
  local BOLD CYAN RESET
  BOLD="$(printf '\033[1m')"
  CYAN="$(printf '\033[36m')"
  RESET="$(printf '\033[0m')"

  if [ ! -d "$dir" ]; then
    printf 'Directorio no encontrado: %s\n' "$dir" >&2
    return 1
  fi

  grep -h '^# @cmd' "$dir"/*.sh 2>/dev/null |
    sed 's/^# @cmd[[:space:]]\+//' |
    sort |
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      local name desc
      name="${line%%[[:space:]]*}"
      desc="${line#"$name"}"
      desc="${desc#" "}"
      printf '%s%-18s%s %s\n' "${BOLD}${CYAN}" "$name" "$RESET" "$desc"
    done
}

# @cmd blib-help  Buscar funciones de bash_lib con fzf
blib-help() {
  _req fzf || return 1

  local dir="${BASH_LIB_DIR:-$HOME/.bash_lib}"
  if [ ! -d "$dir" ]; then
    printf 'Directorio bash_lib no encontrado: %s\n' "$dir" >&2
    return 1
  fi

  local entries
  entries="$(
    grep -Hn '^# @cmd' "$dir"/*.sh 2>/dev/null |
      while IFS=: read -r file line rest; do
        # rest empieza por "# @cmd "
        rest="${rest#'# @cmd '}"
        name="${rest%%[[:space:]]*}"
        desc="${rest#"$name"}"
        desc="${desc#" "}"
        printf '%s\t%s\t%s:%s\n' "$name" "$desc" "$file" "$line"
      done
  )" || true

  if [ -z "$entries" ]; then
    printf 'No se han encontrado funciones documentadas con # @cmd en %s\n' "$dir" >&2
    return 1
  fi

  local sel
  sel="$(
    printf '%s\n' "$entries" |
      fzf --prompt=' bash_lib > ' \
        --delimiter=$'\t' \
        --with-nth=1,2 \
        --no-sort \
        --preview='
            file=$(echo {3} | cut -d: -f1)
            line=$(echo {3} | cut -d: -f2)
            if [ -f "$file" ]; then
              start=$(( line > 5 ? line - 5 : 1 ))
              end=$(( line + 20 ))
              if command -v bat >/dev/null 2>&1; then
                bat --style=numbers --color=always "$file" \
                  | sed -n "${start},${end}p"
              else
                nl -ba "$file" | sed -n "${start},${end}p"
              fi
            fi
          ' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$sel" ] && return 0

  local name
  name="${sel%%$'\t'*}"

  printf 'Función seleccionada: %s\n' "$name" >&2
  printf '%s\n' "$name"
}

# @cmd php_new  Crear nuevo microservicio PHP a partir del skeleton
# Uso:
#   php_new NOMBRE           -> crea $WORKSPACE_ROOT/NOMBRE (o $PWD/NOMBRE)
#
php_new() {
  local name="$1"

  if [[ -z "$name" ]]; then
    printf 'Uso: php_new NOMBRE_PROYECTO\n' >&2
    return 1
  fi

  # Directorio de la plantilla (ajusta si la tienes en otro sitio)
  local template_dir="${PHP_APP_TEMPLATE_DIR:-$HOME/Templates/php-microservice-skel}"

  if [[ ! -d "$template_dir" ]]; then
    printf 'ERROR: plantilla no encontrada en %s\n' "$template_dir" >&2
    return 1
  fi

  # Raíz de trabajo (si tienes WORKSPACE_ROOT, úsalo; si no, PWD)
  local base="${WORKSPACE_ROOT:-$PWD}"
  local dest="$base/$name"

  if [[ -e "$dest" ]]; then
    printf 'ERROR: el destino "%s" ya existe.\n' "$dest" >&2
    return 1
  fi

  printf 'Creando proyecto en %s usando plantilla %s\n' "$dest" "$template_dir"

  # Copia limpia
  cp -a "$template_dir" "$dest" || {
    printf 'ERROR: fallo al copiar la plantilla.\n' >&2
    return 1
  }

  # Limpia historial git de la plantilla e inicializa uno nuevo
  rm -rf "$dest/.git"

  (
    cd "$dest" || exit 1
    git init >/dev/null 2>&1 || true
    git add . >/dev/null 2>&1 || true
    git commit -m "Bootstrap from php-microservice-skel" >/dev/null 2>&1 || true
  )

  # Confía en .mise.toml si existe y está mise
  if command -v mise >/dev/null 2>&1 && [[ -f "$dest/.mise.toml" ]]; then
    (
      cd "$dest" || exit 1
      mise trust .mise.toml || {
        printf 'AVISO: "mise trust .mise.toml" ha fallado, revisalo en %s.\n' "$dest" >&2
      }
    )
  fi

  # Instala dependencias dentro del contenedor, si docker está disponible
  if command -v docker >/dev/null 2>&1 && [[ -f "$dest/docker-compose.yml" ]]; then
    printf 'Instalando dependencias con docker compose run php composer install...\n'
    (
      cd "$dest" || exit 1
      docker compose run --rm php composer install || {
        printf 'AVISO: "composer install" ha fallado, revísalo manualmente en %s.\n' "$dest" >&2
      }
    )
  else
    printf 'AVISO: no se ha encontrado docker o docker-compose.yml; instala dependencias manualmente.\n' >&2
  fi

  printf 'Proyecto PHP creado en: %s\n' "$dest"
  printf 'Siguiente pasos típicos:\n'
  printf '  cd %s\n' "$dest"
  printf '  mise run up   # levanta el servicio\n'
  printf '  mise run test # ejecuta tests\n'
}
