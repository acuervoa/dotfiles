#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/check-nvim.sh [opciones]

Validación headless de la configuración versionada de Neovim.

Opciones:
  --static       Comprueba archivos Lua y lockfile sin arrancar Neovim
  --headless     Carga la configuración y verifica contratos básicos
  --strict       Falla si Neovim o luac no están disponibles
  -h, --help     Muestra esta ayuda
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/stow/nvim/.config/nvim"
STATIC_ONLY=false
HEADLESS_ONLY=false
STRICT=false

while (($# > 0)); do
  case "$1" in
  --static) STATIC_ONLY=true ;;
  --headless) HEADLESS_ONLY=true ;;
  --strict) STRICT=true ;;
  -h | --help) usage; exit 0 ;;
  *) printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ "$STATIC_ONLY" = true ] && [ "$HEADLESS_ONLY" = true ]; then
  printf '[ERROR] --static y --headless son excluyentes\n' >&2
  exit 2
fi

check_static() {
  local -a files=()
  local file
  files+=("$CONFIG/init.lua" "$CONFIG/lazy-lock.json")
  while IFS= read -r file; do files+=("$file"); done < <(find "$CONFIG/lua" -type f -name '*.lua' -print | sort)

  for file in "${files[@]}"; do
    [ -f "$file" ] || { printf '[ERROR] Falta archivo: %s\n' "$file" >&2; return 1; }
  done

  if command -v luac >/dev/null 2>&1; then
    while IFS= read -r file; do luac -p "$file"; done < <(find "$CONFIG/lua" -type f -name '*.lua' -print | sort)
  elif [ "$STRICT" = true ]; then
    printf '[ERROR] luac no está instalado\n' >&2
    return 1
  else
    printf '[WARN] luac no está instalado; se omite parseo Lua\n' >&2
  fi

  printf '[OK] Estructura y lockfile de Neovim válidos\n'
}

check_headless() {
  if ! command -v nvim >/dev/null 2>&1; then
    if [ "$STRICT" = true ]; then
      printf '[ERROR] nvim no está instalado\n' >&2
      return 1
    fi
    printf '[WARN] nvim no está instalado; se omite carga headless\n' >&2
    return 0
  fi

  timeout 60 nvim --headless -u "$CONFIG/init.lua" \
    '+lua assert(vim.g.mapleader == " ", "mapleader inesperado")' \
    '+lua assert(vim.fn.exists(":CodexExplain") == 2, "CodexExplain ausente")' \
    '+qa'
  printf '[OK] Configuración Neovim carga headless\n'
}

if [ "$HEADLESS_ONLY" != true ]; then check_static; fi
if [ "$STATIC_ONLY" != true ]; then check_headless; fi
