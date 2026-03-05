#!/usr/bin/env bash
set -euo pipefail

# Shared helpers/paths for dotfiles scripts.
# - Stable repo-root discovery (even when DOTFILES is unset)
# - XDG-compliant state dirs by default
# - Backwards-compat symlinks in repo (.backups/.manifests)
# - Safe manifest parsing (no `source`)

_repo_root_from_here() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # .../scripts/lib
  (cd "$here/../.." && pwd)
}

REPO_DIR="${DOTFILES:-$(_repo_root_from_here)}"
REPO_DIR="${REPO_DIR/#\~/$HOME}"
STOW_DIR="$REPO_DIR/stow"
: "$STOW_DIR"

STATE_DIR="${DOTFILES_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles}"
BACKUP_BASE="${DOTFILES_BACKUP_DIR:-$STATE_DIR/backups}"
MANIFEST_DIR="${DOTFILES_MANIFEST_DIR:-$STATE_DIR/manifests}"

ensure_state_dirs() { mkdir -p "$BACKUP_BASE" "$MANIFEST_DIR"; }

ensure_compat_links() {
  if ! ln -sfn "$BACKUP_BASE" "$REPO_DIR/.backups" 2>/dev/null; then
    printf '[WARN] No pude actualizar enlace .backups (%s)\n' "$REPO_DIR/.backups" >&2
  fi
  if ! ln -sfn "$MANIFEST_DIR" "$REPO_DIR/.manifests" 2>/dev/null; then
    printf '[WARN] No pude actualizar enlace .manifests (%s)\n' "$REPO_DIR/.manifests" >&2
  fi
}

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] && return 0
  [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version && return 0
  return 1
}

resolve_host() {
  if [ -n "${DOTFILES_HOST:-}" ]; then
    if [[ "$DOTFILES_HOST" =~ ^[A-Za-z0-9._-]+$ ]]; then
      printf '%s' "$DOTFILES_HOST"
      return 0
    fi
    printf '[WARN] DOTFILES_HOST inválido; se ignora\n' >&2
  fi

  if command -v hostname >/dev/null 2>&1; then
    hostname -s 2>/dev/null || hostname 2>/dev/null || true
  fi
}

latest_manifest() {
  [ -d "$MANIFEST_DIR" ] || return 1
  local latest="" f
  shopt -s nullglob
  for f in "$MANIFEST_DIR"/*.manifest; do
    latest="$f"
  done
  shopt -u nullglob
  [ -n "$latest" ] || return 1
  printf '%s' "$latest"
}

latest_backup() {
  [ -d "$BACKUP_BASE" ] || return 1
  local latest="" d
  shopt -s nullglob
  for d in "$BACKUP_BASE"/*; do
    [ -d "$d" ] || continue
    latest="$d"
  done
  shopt -u nullglob
  [ -n "$latest" ] || return 1
  printf '%s' "$latest"
}

manifest_get_string() {
  local manifest="$1" key="$2" out_var="$3"
  # shellcheck disable=SC2178
  local -n out="$out_var"
  local line="" val=""

  while IFS= read -r line; do
    case "$line" in
    "$key"=*)
      val="${line#*=}"
      val="${val#\"}"
      val="${val%\"}"
      break
      ;;
    esac
  done <"$manifest"

  out="$val"
}

manifest_get_array() {
  local manifest="$1" key="$2" out_var="$3"
  # shellcheck disable=SC2178
  local -n out="$out_var"
  local line="" val=""

  while IFS= read -r line; do
    case "$line" in
    "$key"=\(*)
      val="${line#*=}"
      val="${val#(}"
      val="${val%)}"
      break
      ;;
    esac
  done <"$manifest"

  local -a tmp=()
  if [ -n "$val" ]; then
    read -r -a tmp <<<"$val"
  fi

  out=()  # reset
  if [ "${#tmp[@]}" -gt 0 ]; then
    out=("${tmp[@]}")
  fi
  : "${out[@]}"
}

manifest_get_bool() {
  local manifest="$1" key="$2" out_var="$3"
  local raw=""
  manifest_get_string "$manifest" "$key" raw
  case "$raw" in
  true|false) ;; # ok
  *) raw="" ;; # unknown/legacy
  esac
  printf -v "$out_var" '%s' "$raw"
}
