#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/verify.sh [opciones]

Corre verificaciones livianas del repo (read-only):
- scripts/check.sh
- scripts/check-secrets.sh
- nvim --headless "+checkhealth" +qa (if available)
- nvim --headless "+lua require('config.options')" +qa (optional)

Opciones:
  -h, --help       Muestra esta ayuda
  --no-nvim        Omite checkhealth de Neovim
  --no-scan        Omite check-secrets
  --nvim-config    También carga config.options headless
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

NO_NVIM=false
NO_SCAN=false
NVIM_CONFIG=false

while (($# > 0)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --no-nvim)
    NO_NVIM=true
    ;;
  --no-scan)
    NO_SCAN=true
    ;;
  --nvim-config)
    NVIM_CONFIG=true
    ;;
  *)
    printf '%s\n' "[ERROR] Opción no reconocida: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

main() {
  if [ -x "$REPO_DIR/scripts/check.sh" ]; then
    info "Corriendo scripts/check.sh"
    "$REPO_DIR/scripts/check.sh"
  else
    warn "No existe scripts/check.sh (omito)"
  fi

  if [ "$NO_SCAN" = "true" ]; then
    info "Omitiendo check-secrets (--no-scan)."
  elif [ -x "$REPO_DIR/scripts/check-secrets.sh" ]; then
    info "Corriendo scripts/check-secrets.sh"
    "$REPO_DIR/scripts/check-secrets.sh"
  else
    warn "No existe scripts/check-secrets.sh (omito)"
  fi

  if [ "$NO_NVIM" = "true" ]; then
    info "Omitiendo checkhealth de Neovim (--no-nvim)."
  elif command -v nvim >/dev/null 2>&1; then
    info "Corriendo checkhealth de Neovim (headless)"
    nvim --headless "+checkhealth" +qa
    if [ "$NVIM_CONFIG" = "true" ]; then
      info "Corriendo carga de config.options (headless)"
      nvim --headless "+lua require('config.options')" +qa
    fi
  else
    warn "nvim no está instalado; omito checkhealth."
  fi
}

main
