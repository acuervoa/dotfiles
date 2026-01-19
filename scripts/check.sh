#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/check.sh [options]

Runs standardized repo validation for shell code:
- `bash -n` on `scripts/*.sh` and `stow/bash/.bash_lib/*.sh`
- `shellcheck` on the same files (if installed)

Options:
  -h, --help        Show this help
  --no-shellcheck   Skip ShellCheck even if installed

Exit codes:
  0  All enabled checks passed
  1  A check failed
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

while (($# > 0)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --no-shellcheck)
    NO_SHELLCHECK=true
    ;;
  *)
    printf '[ERROR] Unknown option: %s\n' "$1" >&2
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
  files+=("$REPO_ROOT"/stow/bash/.bash_lib/*.sh)
  files+=("$REPO_ROOT"/stow/dotfiles/.config/dotfiles/hosts/*.sh)

  if [ "${#files[@]}" -eq 0 ]; then
    warn "No shell files found to check."
    return 0
  fi

  action BASH "Syntax check (bash -n)"
  local f
  for f in "${files[@]}"; do
    bash -n "$f"
  done

  if [ "$NO_SHELLCHECK" = "true" ]; then
    info "Skipping shellcheck (--no-shellcheck)."
    return 0
  fi

  if ! command -v shellcheck >/dev/null 2>&1; then
    warn "shellcheck not installed; skipping."
    return 0
  fi

  action SHELLCHECK "Lint (shellcheck)"
  shellcheck "${files[@]}"
}

main
