#!/usr/bin/env bash
# Uso: pane_jobs.sh <pane_pid>
PPID="$1"
[[ -z "$PPID" ]] && { echo "0"; exit 0; }

# Cuenta descendientes vivos excluyendo la shell/pipes triviales
count_desc() {
  local p="$1"
  local kids
  kids=$(pgrep -P "$p") || return 0
  local c=0
  for k in $kids; do
    # ignora el shell interactivo y tmux helper
    comm=$(ps -o comm= -p "$k" 2>/dev/null)
    case "$comm" in
      bash|zsh|fish|tmux|sh) ;;
      *) c=$((c+1));;
    esac
    c=$((c + $(count_desc "$k")))
  done
  echo "$c"
}
count_desc "$PPID"

