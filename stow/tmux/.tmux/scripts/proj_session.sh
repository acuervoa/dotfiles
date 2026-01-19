#!/usr/bin/env bash
set -euo pipefail

# Gestion rápida de sesiones/proyectos
# Subcomandos: new [name], ls, attach [name], pick

cmd=${1:-}
shift || true

# Helpers
err() { printf '%s\n' "$*" >&2; }
tmux_bin=${TMUX_BIN:-tmux}

list_sessions() {
  "$tmux_bin" list-sessions -F '#S' 2>/dev/null || true
}

choose() {
  # stdin: lista de opciones
  if command -v fzf >/dev/null 2>&1; then
    fzf --no-multi --prompt='session> ' --height=80% --border
  else
    # fallback: primera línea (sin interactividad)
    head -n 1
  fi
}

pick_path() {
  local tmpfile
  tmpfile=$(mktemp)
  # 1) zoxide recientes (si existe)
  if command -v zoxide >/dev/null 2>&1; then
    zoxide query -l >"$tmpfile" || true
  fi
  # 2) Workspace entries (añadir si no están ya)
  local ws="$HOME/Workspace"
  if [ -d "$ws" ]; then
    while IFS= read -r d; do
      [ -d "$d" ] || continue
      # dedup: grep -Fxq
      if ! grep -Fxq -- "$d" "$tmpfile" 2>/dev/null; then
        printf '%s\n' "$d" >>"$tmpfile"
      fi
    done < <(find "$ws" -mindepth 1 -maxdepth 1 -type d | sort)
  fi
  if [ ! -s "$tmpfile" ]; then
    rm -f "$tmpfile"
    return 1
  fi
  local choice
  choice=$(cat "$tmpfile" | choose)
  rm -f "$tmpfile"
  [ -n "$choice" ] || return 1
  printf '%s\n' "$choice"
}

new_session() {
  local name=${1:-}
  local cwd
  cwd=$(pwd)
  if [ -z "$name" ]; then
    name=$(basename "$cwd")
  fi
  # si ya existe, adjunta
  if "$tmux_bin" has-session -t "$name" 2>/dev/null; then
    "$tmux_bin" switch-client -t "$name" 2>/dev/null || "$tmux_bin" attach-session -t "$name"
    return 0
  fi
  "$tmux_bin" new-session -d -s "$name" -c "$cwd"
  if [ -n "$TMUX" ]; then
    "$tmux_bin" switch-client -t "$name"
  else
    "$tmux_bin" attach-session -t "$name"
  fi
}

attach_session() {
  local name=${1:-}
  local current
  current=$("$tmux_bin" display-message -p '#S' 2>/dev/null || true)
  mapfile -t sessions < <(list_sessions)
  if [ -z "$name" ]; then
    # quitar la sesión actual de la lista
    sessions=("${sessions[@]/$current}")
    # limpiar vacíos
    tmp=()
    for s in "${sessions[@]}"; do
      [ -n "$s" ] && tmp+=("$s")
    done
    sessions=(${tmp[@]:-})
    if [ ${#sessions[@]} -eq 0 ]; then
      err "No hay otra sesión"
      return 1
    fi
    if [ ${#sessions[@]} -eq 1 ]; then
      name=${sessions[0]}
    else
      name=$(printf '%s\n' "${sessions[@]}" | choose)
    fi
  fi
  [ -n "$name" ] || return 1
  if [ -n "$TMUX" ]; then
    "$tmux_bin" switch-client -t "$name"
  else
    "$tmux_bin" attach-session -t "$name"
  fi
}

pick_project() {
  local path
  path=$(pick_path) || { err "Sin candidatos"; return 1; }
  local name
  name=$(basename "$path")
  if "$tmux_bin" has-session -t "$name" 2>/dev/null; then
    if [ -n "$TMUX" ]; then
      "$tmux_bin" switch-client -t "$name"
    else
      "$tmux_bin" attach-session -t "$name"
    fi
    return 0
  fi
  "$tmux_bin" new-session -d -s "$name" -c "$path"
  if [ -n "$TMUX" ]; then
    "$tmux_bin" switch-client -t "$name"
  else
    "$tmux_bin" attach-session -t "$name"
  fi
}

case "$cmd" in
  new)    new_session "${1:-}" ;;
  ls)     list_sessions ;;
  attach) attach_session "${1:-}" ;;
  pick)   pick_project ;;
  *)      err "Uso: $0 {new [name]|ls|attach [name]|pick}"; exit 1 ;;
esac
