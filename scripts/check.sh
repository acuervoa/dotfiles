#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/check.sh [opciones]

Ejecuta validaciones estándar para scripts shell:
- `bash -n` on `scripts/*.sh`, `scripts/lib/*.sh`, and `stow/bash/.bash_lib/*.sh`
- `shellcheck` sobre los mismos archivos (si está instalado)
- `shfmt -d` sobre los mismos archivos (si está instalado)

Opciones:
  -h, --help        Muestra esta ayuda
  --no-shellcheck   Omite ShellCheck aunque esté instalado
  --no-shfmt        Omite shfmt aunque esté instalado

Ejemplo (entorno mínimo):
  scripts/check.sh --no-shellcheck --no-shfmt

Códigos de salida:
  0  Todos los checks habilitados pasaron
  1  Algún check falló
USAGE
}

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift
  printf '[%s] %s\n' "$kind" "$*"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NO_SHELLCHECK=false
NO_SHFMT=false

while (($# > 0)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --no-shellcheck)
    NO_SHELLCHECK=true
    ;;
  --no-shfmt)
    NO_SHFMT=true
    ;;
  *)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

main() {
  shopt -s nullglob

  local -a files=()
  files+=("$REPO_ROOT"/scripts/*.sh)
  files+=("$REPO_ROOT"/scripts/lib/*.sh)
  files+=("$REPO_ROOT"/stow/bash/.bash_lib/*.sh)
  files+=("$REPO_ROOT"/stow/dotfiles/.config/dotfiles/hosts/*.sh)

  if [ "${#files[@]}" -eq 0 ]; then
    warn "No se encontraron archivos shell para revisar."
    return 0
  fi

  action BASH "Syntax check (bash -n)"
  local f
  for f in "${files[@]}"; do
    bash -n "$f"
  done

  if [ "$NO_SHFMT" = "true" ]; then
    info "Omitiendo shfmt (--no-shfmt)."
  elif ! command -v shfmt >/dev/null 2>&1; then
    warn "shfmt no está instalado; omitiendo."
  else
    action SHFMT "Format check (shfmt -d)"
    shfmt -d -i 2 "${files[@]}"
  fi

  if [ "$NO_SHELLCHECK" = "true" ]; then
    info "Omitiendo shellcheck (--no-shellcheck)."
    return 0
  fi

  if ! command -v shellcheck >/dev/null 2>&1; then
    warn "shellcheck no está instalado; omitiendo."
    return 0
  fi

  action SHELLCHECK "Lint (shellcheck)"
  # Default a warnings+errors. Infos are often intentional in dotfiles.
  # Run `shellcheck` manually if you want the full verbosity.
  shellcheck -S warning "${files[@]}"
}

main
