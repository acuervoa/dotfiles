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
# @ cmd _edit_at  Abrir fichero en $EDITOR en una linea concreta (si se facilita)
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
  local dir="${1:-$HOME/dotfiles/bash/bash_lib}"
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
      [ -z "$line" ] && contiunue
      local name desc
      name="${line%%[[:space:]]*}"
      desc="${line#"$name"}"
      desc="${desc#" "}"
      printf '%s%-18s%s %s\n' "${BOLD}${CYAN}" "$name" "$RESET" "$desc"
    done
}
