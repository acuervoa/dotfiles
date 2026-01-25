#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/doctor.sh [opciones]

Chequeos rapidos (read-only) para validar que el repo y el host estan listos
para correr bootstrap/rollback.

Opciones:
  -n, --no-lint       No correr scripts/check.sh
  --no-conflicts      No chequear conflictos de stow
  --core-only         Modo core (omite GUI)
  --gui               Fuerza incluir GUI
  -h, --help          Muestra esta ayuda

Variables de entorno:
  DOTFILES            Ruta al repo (por defecto, carpeta raiz del script)
  DOTFILES_HOST       Override del hostname para perfiles
USAGE
}

NO_LINT=false
NO_CONFLICTS=false
GUI_MODE="auto" # auto|on|off

while (($# > 0)); do
  case "$1" in
  -n | --no-lint)
    NO_LINT=true
    ;;
  --no-conflicts)
    NO_CONFLICTS=true
    ;;
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

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
err() { printf '[ERROR] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift
  printf '[%s] %s\n' "$kind" "$*"
}

require_cmd() {
  local c
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      err "Falta comando requerido: $c"
      return 1
    fi
  done
}

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

  # Inicializar para evitar variables vacias si el default no existe.
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
      info "Cargando perfil de host: $host"
      # shellcheck source=/dev/null
      source "$host_profile"
    else
      info "Sin perfil especifico para host '$host' (uso default)"
    fi
  else
    warn "No pude determinar hostname; uso perfil default"
  fi
}

check_pkg_dirs() {
  local ok=true pkg

  for pkg in "$@"; do
    if [ ! -d "$STOW_DIR/$pkg" ]; then
      err "Paquete stow inexistente: $pkg"
      ok=false
    fi
  done

  $ok || return 1
}

check_stow_conflicts() {
  local pkg="$1"

  # Solo mostramos conflictos reales; el resto del output de stow suele ser ruido.
  local out
  out="$(
    stow -d "$STOW_DIR" -t "$HOME" -nS "$pkg" 2>&1 |
      grep -E 'existing target is not (a symlink|owned by stow|a directory|a link nor a directory):' || true
  )"

  if [ -n "$out" ]; then
    warn "Conflictos para '$pkg':"
    printf '%s\n' "$out" >&2
    return 1
  fi

  return 0
}

main() {
  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"

  [ -d "$REPO_DIR" ] || { err "Repo no encontrado: $REPO_DIR"; return 1; }
  [ -d "$STOW_DIR" ] || { err "Directorio stow no encontrado: $STOW_DIR"; return 1; }

  action DEPS "Verificando dependencias"
  require_cmd stow || return 1
  require_cmd rsync || warn "rsync no esta instalado (rollback lo requiere)"

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

  action PKGS "Verificando paquetes stow"
  # dotfiles siempre deberia existir porque contiene los perfiles.
  check_pkg_dirs dotfiles "${home_pkgs[@]}" "${config_pkgs[@]}" || return 1

  if [ "$NO_CONFLICTS" != "true" ]; then
    action CONFLICTS "Chequeando conflictos de stow (dry-run)"

    local ok=true pkg
    for pkg in dotfiles "${home_pkgs[@]}" "${config_pkgs[@]}"; do
      if ! check_stow_conflicts "$pkg"; then
        ok=false
      fi
    done

    $ok || return 1
  fi

  if [ "$NO_LINT" != "true" ]; then
    if [ -x "$REPO_DIR/scripts/check.sh" ]; then
      action LINT "Corriendo scripts/check.sh"
      "$REPO_DIR/scripts/check.sh"
    else
      warn "No existe scripts/check.sh (omito lint)"
    fi
  fi

  info "Doctor OK: listo para bootstrap/rollback."
}

main
