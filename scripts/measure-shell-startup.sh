#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/measure-shell-startup.sh [--runs N]

Mide shells Bash login y no-login en un pseudo-TTY. No lee el historial real
ni modifica el HOME del usuario; usa una HOME temporal con los entrypoints
versionados y un .bashrc_local vacío.
USAGE
}

runs=5
while (($# > 0)); do
  case "$1" in
  --runs)
    runs="${2:?Falta N}"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
    exit 2
    ;;
  esac
  shift
done
[[ "$runs" =~ ^[1-9][0-9]*$ ]] || {
  printf '[ERROR] --runs debe ser positivo\n' >&2
  exit 2
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_home="$(mktemp -d)"
trap 'rm -rf -- "$temp_home"' EXIT
ln -s "$repo_root/stow/bash/.bashrc" "$temp_home/.bashrc"
ln -s "$repo_root/stow/bash/.bash_profile" "$temp_home/.bash_profile"
ln -s "$repo_root/stow/bash/.profile" "$temp_home/.profile"
ln -s "$repo_root/stow/bash/.bash_aliases" "$temp_home/.bash_aliases"
ln -s "$repo_root/stow/bash/.bash_functions" "$temp_home/.bash_functions"
ln -s "$repo_root/stow/bash/.bash_grammar" "$temp_home/.bash_grammar"
ln -s "$repo_root/stow/bash/.bash_lib" "$temp_home/.bash_lib"
: >"$temp_home/.bashrc_local"
: >"$temp_home/.bash_history"

measure() {
  local label="$1" login_flag="$2" i start end
  printf '%s:' "$label"
  for ((i = 1; i <= runs; i++)); do
    start="$(date +%s%N)"
    HOME="$temp_home" HISTFILE="$temp_home/.bash_history" \
      bash $login_flag -i -c 'printf . >/dev/null' </dev/null >/dev/null 2>&1 || true
    end="$(date +%s%N)"
    printf ' %0.3f' "$((end - start))e-9"
  done
  printf '\n'
}

printf '# Bash startup measurement (runs=%s)\n' "$runs"
measure no-login ''
measure login '-l'
