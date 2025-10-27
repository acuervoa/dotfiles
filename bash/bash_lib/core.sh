#!/usr/bin/env bash
# core.sh — funciones útiles no cubiertas por aliases

# Comprueba binarios requeridos antes de ejecutar la función
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

# Abre archivo en el editor preferido.
# Respeta $VISUAL, luego $EDITOR. Fallback a nvim/vim/nano.
# Si se pasa número de línea y el editor soporta "+<line>", lo usa.
_edit_at() {
  local file="$1" line="$2" editor

  [ -z "$file" ] && {
    printf 'No hay fichero que abrir.\n' >&2
    return 1
  }

  if [ -n "${VISUAL:-}" ]; then
    editor="$VISUAL"
  elif [ -n "${EDITOR:-}" ]; then
    editor="$EDITOR"
  elif command -v nvim >/dev/null 2>&1; then
    editor="nvim"
  elif command -v vim >/dev/null 2>&1; then
    editor="vim"
  else
    editor="nano"
  fi

  if [ -n "$line" ]; then
    "$editor" "+${line}" -- "$file"
  else
    "$editor" -- "$file"
  fi
}

# Matar procesos con confirmación
# - No mata ciegamente con -9
# - Evita matar PID 1, tu propio shell
# - Envia SIGTERM primero, luego opcional SIGKILL
# - Pide confirmación

fkill() {
  _req fzf ps awk kill || return 1

  local sel pids=() line pid
  sel="$(
    ps -eo pid,user,stat,%cpu,%mem,cmd --sort=-%cpu |
      awk 'NR>1' |
      fzf --ansi --multi \
        --prompt=' kill > ' \
        --header='Selecciona procesos a terminar (SPACE para marcar, ENTER para confirmar)' \
        --preview='echo PID:{1}; ps -p {1} -o pid,ppid,user,stat,%cpu,%mem,etime,cmd' \
        --preview-window=down,50%
  )" || return 0

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
  printf '¿Continuar? [y/N] ' >&2
  read -r ans
  [ "$ans" = "y" ] || return 0

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
    printf '¿Forzar con SIGKILL (-9)? [y/N] ' >&2
    read -r force
    [ "$force" = "y" ] && kill -9 -- "${still_up[@]}" 2>/dev/null
  fi
}

# Buscar en el repo con ripgrep + abrir en el editor
# - Maneja patrón vacio
# - Soporta múltiples selecciones
# - Respeta espacios en rutas.
# - Abre el editor saltando a la linea exacta
# - Vista previa recortada centrada en la linea del match

rgf() {
  _req rg fzf bat awk || return 1

  if [ $# -eq 0 ]; then
    printf 'Uso: rgf <patrón de búsqueda>\n' >&2
    return 1
  fi

  local results
  results="$(
    rg --hidden --glob '!.git' --line-number --no-heading --color=never -- "$@" |
      fzf --multi \
        --prompt=' rg > ' \
        --delimiter=':' \
        --nth=3.. \
        --preview='
                    line={2}
                    start=$(( line - 10 ))
                    [ "$start" -lt 1 ] && start=1
                    end=$(( line + 30 ))

                    bat --style=numbers --color=always \
                        --highlight-line "$line" \
                        --line-range "${start}:${end}" \
                        {1} 2>/dev/null
              ' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$results" ] && return 0

  local sel fpath lnum
  while IFS= read -r sel; do
    fpath="$(printf '%s\n' "$sel" | awk -F: '{print $1}')"
    lnum="$(printf '%s\n' "$sel" | awk -F: '{print $2}')"

    [ -n "$fpath" ] && [ -f "$fpath" ] && _edit_at "$fpath" "$lnum"
  done <<<"$results"
}

# Lanzar/adjuntar a una sesión tmux por nombre (default: main)
t() {
  _req tmux || return 1
  local name="${1:-main}"

  if tmux has-session -t "$name" 2>/dev/null; then
    tmux attach -t "$name"
  else
    tmux new -s "$name"
  fi
}

# Papelera en vez de rm directo
trash() {
  _req thrash-put || {
    printf 'Necesito trash-put (paquete trash-cli)\n' >&2
    return 1
  }
  trash-put -- "$@"
}

# volver a ejecutar el último comando interactivo
# - Reejecuta el comando anterior al `redo` leyendo el history.
# - Útil para: "me dio error, ejecuto 'redo' directamente".
# - Limitación: si lo último en el history es literalmente 'redo', entraría bucle.
#   Lo evitamos leyendo el penúltimo comando de history.
redo() {
  local cmd
  cmd="$(history 2 | head -n1 | sed 's/^[ ]*[0-9]\+[ ]*//')"

  if [ -z "$cmd" ]; then
    printf 'No puedo recuperar el último comando.\n' >&2
    return 1
  fi

  printf 'Reejecutando; %s\n' "$cmd" >&2
  eval "$cmd"
}
