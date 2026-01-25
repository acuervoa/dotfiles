#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/status.sh [opciones]

Muestra estado del setup de dotfiles sin modificar nada:
- Host detectado + perfil cargado
- Paquetes segun perfil (core/gui)
- Ultimo manifest/backup (si existen)
- Chequeos rapidos de blesh (.blerc)

Opciones:
  --core-only          Modo core (omite GUI)
  --gui                Fuerza incluir GUI
  -h, --help           Muestra esta ayuda

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raiz del script)
  DOTFILES_HOST        Override del hostname para perfiles
USAGE
}

GUI_MODE="auto" # auto|on|off

while (($# > 0)); do
  case "$1" in
  --core-only)
    GUI_MODE="off"
    ;;
  --gui)
    GUI_MODE="on"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf '[ERROR] Opcion no reconocida: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="${DOTFILES:-$DEFAULT_REPO}"

# state dirs (XDG)
STATE_DIR="${DOTFILES_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles}"
BACKUP_BASE="${DOTFILES_BACKUP_DIR:-$STATE_DIR/backups}"
MANIFEST_DIR="${DOTFILES_MANIFEST_DIR:-$STATE_DIR/manifests}"
mkdir -p "$BACKUP_BASE" "$MANIFEST_DIR"

# compat symlinks inside repo (optional but keeps old paths working)
ln -sfn "$BACKUP_BASE" "$BACKUP_BASE" 2>/dev/null || true
ln -sfn "$MANIFEST_DIR" "$MANIFEST_DIR" 2>/dev/null || true
REPO_DIR="${REPO_DIR/#\~/$HOME}"
STOW_DIR="$REPO_DIR/stow"
MANIFEST_DIR="$MANIFEST_DIR"
BACKUP_BASE="$BACKUP_BASE"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] && return 0
  [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version && return 0
  return 1
}

resolve_host() {
  if [ -n "${DOTFILES_HOST:-}" ]; then
    printf '%s' "$DOTFILES_HOST"
    return 0
  fi

  if command -v hostname >/dev/null 2>&1; then
    hostname -s 2>/dev/null || hostname 2>/dev/null || true
  fi
}

load_host_profile() {
  local host profile_dir default_profile host_profile

  host="$(resolve_host)"
  profile_dir="$STOW_DIR/dotfiles/.config/dotfiles/hosts"
  default_profile="$profile_dir/default.sh"

  HOME_PKGS=()
  CONFIG_CORE_PKGS=()
  CONFIG_GUI_PKGS=()

  if [ -f "$default_profile" ]; then
    # shellcheck source=/dev/null
    source "$default_profile"
  else
    warn "Perfil default no encontrado: $default_profile"
  fi

  if [ -n "$host" ]; then
    host_profile="$profile_dir/$host.sh"
    if [ -f "$host_profile" ]; then
      info "Perfil host: $host_profile"
      # shellcheck source=/dev/null
      source "$host_profile"
    else
      info "Perfil host: (no existe) $host_profile"
    fi
  else
    warn "No pude determinar hostname"
  fi

  info "Perfil default: $default_profile"
}

latest_manifest() {
  [ -d "$MANIFEST_DIR" ] || return 1

  local latest=""
  local f

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

  local latest=""
  local d

  shopt -s nullglob
  for d in "$BACKUP_BASE"/*; do
    [ -d "$d" ] || continue
    latest="$d"
  done
  shopt -u nullglob

  [ -n "$latest" ] || return 1
  printf '%s' "$latest"
}

main() {
  local host
  host="$(resolve_host || true)"

  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"
  info "Host: ${host:-unknown}"

  if is_wsl; then
    info "Entorno: WSL"
  else
    info "Entorno: Linux"
  fi

  load_host_profile

  local include_gui=true
  if is_wsl; then
    include_gui=false
    if [ "$GUI_MODE" = "on" ]; then
      warn "WSL2 detectado; omitiendo GUI aunque se haya pedido --gui."
    fi
  else
    case "$GUI_MODE" in
    off) include_gui=false ;;
    on | auto) include_gui=true ;;
    *) include_gui=true ;;
    esac
  fi

  local -a home_pkgs=("${HOME_PKGS[@]}")
  local -a config_pkgs=("${CONFIG_CORE_PKGS[@]}")
  if [ "$include_gui" = "true" ]; then
    config_pkgs+=("${CONFIG_GUI_PKGS[@]}")
  fi

  echo
  info "Paquetes -> $HOME: ${home_pkgs[*]}"
  info "Paquetes -> $HOME/.config: dotfiles ${config_pkgs[*]}"

  echo
  local mf
  if mf="$(latest_manifest 2>/dev/null)"; then
    info "Manifest (latest): $mf"
    # shellcheck disable=SC1090
    source "$mf"
    info "Manifest host: ${host:-}"
    info "Manifest timestamp: ${timestamp:-}"
  else
    info "Manifest: (ninguno)"
  fi

  local bk
  if bk="$(latest_backup 2>/dev/null)"; then
    info "Backup (latest): $bk"
  else
    info "Backup: (ninguno)"
  fi

  echo
  local blerc="$HOME/.blerc"
  local blerc_xdg="${XDG_CONFIG_HOME:-$HOME/.config}/blesh/blerc"

  if [ -L "$blerc" ]; then
    info ".blerc: symlink -> $(readlink -- "$blerc" 2>/dev/null || true)"
  elif [ -e "$blerc" ]; then
    warn ".blerc: existe pero no es symlink"
  else
    warn ".blerc: no existe"
  fi

  if [ -r "$blerc_xdg" ]; then
    info "blerc XDG: OK ($blerc_xdg)"
  else
    warn "blerc XDG: no legible ($blerc_xdg)"
  fi
}

main
