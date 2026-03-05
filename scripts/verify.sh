#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/verify.sh [options]

Runs lightweight repo verification (read-only):
- scripts/check.sh
- scripts/check-secrets.sh
- nvim --headless "+checkhealth" +qa (if available)
- nvim --headless "+lua require('config.options')" +qa (optional)

Options:
  -h, --help       Show this help
  --no-nvim        Skip Neovim health check
  --no-scan        Skip check-secrets scan
  --nvim-config    Also load config.options headless
USAGE
}

info() { printf '%s\n' "[INFO] $*"; }
warn() { printf '%s\n' "[WARN] $*" >&2; }

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
    printf '%s\n' "[ERROR] Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

main() {
  if [ -x "$REPO_ROOT/scripts/check.sh" ]; then
    info "Running scripts/check.sh"
    "$REPO_ROOT/scripts/check.sh"
  else
    warn "Missing scripts/check.sh (skipping)"
  fi

  if [ "$NO_SCAN" = "true" ]; then
    info "Skipping check-secrets scan (--no-scan)."
  elif [ -x "$REPO_ROOT/scripts/check-secrets.sh" ]; then
    info "Running scripts/check-secrets.sh"
    "$REPO_ROOT/scripts/check-secrets.sh"
  else
    warn "Missing scripts/check-secrets.sh (skipping)"
  fi

  if [ "$NO_NVIM" = "true" ]; then
    info "Skipping Neovim health check (--no-nvim)."
  elif command -v nvim >/dev/null 2>&1; then
    info "Running Neovim checkhealth (headless)"
    nvim --headless "+checkhealth" +qa
    if [ "$NVIM_CONFIG" = "true" ]; then
      info "Running Neovim config load (headless)"
      nvim --headless "+lua require('config.options')" +qa
    fi
  else
    warn "nvim not installed; skipping checkhealth."
  fi
}

main
