#!/usr/bin/env bash
set -euo pipefail

# Shared helpers/paths for dotfiles scripts.
# - Stable repo-root discovery (even when DOTFILES is unset)
# - XDG-compliant state dirs by default
# - Backwards-compat symlinks in repo (.backups/.manifests)

_repo_root_from_here() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # .../scripts/lib
  (cd "$here/../.." && pwd)
}

REPO_DIR="${DOTFILES:-$(_repo_root_from_here)}"
REPO_DIR="${REPO_DIR/#\~/$HOME}"
STOW_DIR="$REPO_DIR/stow"

STATE_DIR="${DOTFILES_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles}"
BACKUP_BASE="${DOTFILES_BACKUP_DIR:-$STATE_DIR/backups}"
MANIFEST_DIR="${DOTFILES_MANIFEST_DIR:-$STATE_DIR/manifests}"

ensure_state_dirs() { mkdir -p "$BACKUP_BASE" "$MANIFEST_DIR"; }

ensure_compat_links() {
  ln -sfn "$BACKUP_BASE" "$REPO_DIR/.backups" 2>/dev/null || true
  ln -sfn "$MANIFEST_DIR" "$REPO_DIR/.manifests" 2>/dev/null || true
}
