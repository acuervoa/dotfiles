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

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift

  if [ "${DRY_RUN:-false}" = "true" ]; then
    printf '[DRY-RUN][%s] %s\n' "$kind" "$*"
  else
    printf '[%s] %s\n' "$kind" "$*"
  fi
}

run_cmd() {
  if [ "${DRY_RUN:-false}" = "true" ]; then
    return 0
  fi
  "$@"
}

confirm() {
  local msg="${1:-¿Continuar? [y/N] }" ans

  if [ "${ASSUME_YES:-false}" = "true" ]; then
    return 0
  fi

  printf '%s' "$msg" >&2
  read -r ans
  case "$ans" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

require_cmd() {
  local c
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      printf '[ERROR] Este script requiere %s instalado.\n' "$c" >&2
      exit 1
    fi
  done
}

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

manifest_path_for_input() {
  local selected_input="${1:-latest}"

  if [ "$selected_input" = "latest" ]; then
    latest_manifest
    return $?
  fi

  local candidate="$MANIFEST_DIR/$selected_input.manifest"
  [ -f "$candidate" ] || return 1
  printf '%s' "$candidate"
}

backup_path_for_input() {
  local selected_input="${1:-latest}"

  if [ "$selected_input" = "latest" ]; then
    latest_backup
    return $?
  fi

  local candidate="$BACKUP_BASE/$selected_input"
  [ -d "$candidate" ] || return 1
  printf '%s' "$candidate"
}

load_host_packages_profile() {
  local host profile_dir default_profile host_profile

  host="$(resolve_host)"
  profile_dir="$STOW_DIR/dotfiles/.config/dotfiles/hosts"
  default_profile="$profile_dir/default.sh"
  # shellcheck disable=SC2034 # variable de estado para scripts que hacen source
  DOTFILES_PROFILE_DEFAULT="$default_profile"
  # shellcheck disable=SC2034 # variable de estado para scripts que hacen source
  DOTFILES_PROFILE_HOST=""

  # Inicializar arrays para evitar valores heredados o variables vacías.
  # shellcheck disable=SC2034 # array consumido por scripts que hacen source
  HOME_PKGS=()
  # shellcheck disable=SC2034 # array consumido por scripts que hacen source
  CONFIG_CORE_PKGS=()
  # shellcheck disable=SC2034 # array consumido por scripts que hacen source
  CONFIG_GUI_PKGS=()

  if [ -f "$default_profile" ]; then
    # shellcheck source=/dev/null
    source "$default_profile"
  else
    printf '[WARN] Perfil default no encontrado: %s\n' "$default_profile" >&2
  fi

  if [ -n "$host" ]; then
    host_profile="$profile_dir/$host.sh"
    # shellcheck disable=SC2034 # variable de estado para scripts que hacen source
    DOTFILES_PROFILE_HOST="$host_profile"
    if [ -f "$host_profile" ]; then
      printf '[INFO] Cargando perfil de host: %s\n' "$host"
      # shellcheck source=/dev/null
      source "$host_profile"
    else
      printf '[INFO] Sin perfil especifico para host %q (uso default)\n' "$host"
    fi
  else
    printf '[WARN] No pude determinar hostname; uso perfil default\n' >&2
  fi
}

should_include_gui_packages() {
  local gui_mode="${1:-auto}"

  if is_wsl; then
    if [ "$gui_mode" = "on" ]; then
      warn "WSL2 detectado; omitiendo GUI aunque se haya pedido --gui."
    fi
    return 1
  fi

  case "$gui_mode" in
  off) return 1 ;;
  on | auto | "") return 0 ;;
  *) return 0 ;;
  esac
}

build_config_packages() {
  local gui_mode="${1:-auto}" out_var="$2"
  # shellcheck disable=SC2178
  local -n out="$out_var"

  out=("${CONFIG_CORE_PKGS[@]}")
  if should_include_gui_packages "$gui_mode"; then
    out+=("${CONFIG_GUI_PKGS[@]}")
  fi
}

run_stow_package() {
  local pkg="$1" target_dir="$2" operation="$3" message="$4"

  if [ ! -d "$STOW_DIR/$pkg" ]; then
    warn "Paquete stow inexistente (omito): $pkg"
    return 1
  fi

  action STOW "$message"
  run_cmd stow -d "$STOW_DIR" -t "$target_dir" "$operation" "$pkg"
}

log_info_value() {
  local log_file="$1" key="$2"
  local prefix="[INFO] $key: "
  local line="" value=""

  [ -f "$log_file" ] || return 1

  while IFS= read -r line; do
    case "$line" in
    "$prefix"*) value="${line#"$prefix"}" ;;
    esac
  done <"$log_file"

  [ -n "$value" ] || return 1
  printf '%s' "$value"
}

latest_manifest_summary() {
  local mf="$1"
  local out_path_var="$2" out_host_var="$3" out_timestamp_var="$4" out_backup_var="$5"
  # shellcheck disable=SC2034,SC2178 # namerefs de salida usados por el caller
  # shellcheck disable=SC2178
  local -n out_path="$out_path_var"
  # shellcheck disable=SC2178
  local -n out_host="$out_host_var"
  # shellcheck disable=SC2178
  local -n out_timestamp="$out_timestamp_var"
  # shellcheck disable=SC2178
  local -n out_backup="$out_backup_var"
  local backup_abs="" backup_rel=""

  # shellcheck disable=SC2034 # nameref de salida consumido por el caller
  out_path="$mf"
  # shellcheck disable=SC2034 # nameref de salida consumido por el caller
  out_host=""
  # shellcheck disable=SC2034 # nameref de salida consumido por el caller
  out_timestamp=""
  # shellcheck disable=SC2034 # nameref de salida consumido por el caller
  out_backup=""

  manifest_get_string "$mf" host out_host
  manifest_get_string "$mf" timestamp out_timestamp
  manifest_get_string "$mf" backup_dir_abs backup_abs
  manifest_get_string "$mf" backup_dir_rel backup_rel

  if [ -n "$backup_abs" ]; then
    # shellcheck disable=SC2034 # nameref de salida consumido por el caller
    out_backup="$backup_abs"
  elif [ -n "$backup_rel" ]; then
    # shellcheck disable=SC2034 # nameref de salida consumido por el caller
    out_backup="$REPO_DIR/$backup_rel"
  fi
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

  # shellcheck disable=SC2178 # nameref puede apuntar a escalar o array según caller
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
