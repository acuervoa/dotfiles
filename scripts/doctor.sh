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
  --json              Output JSON (stdout) para tooling
  -h, --help          Muestra esta ayuda

Variables de entorno:
  DOTFILES            Ruta al repo (por defecto, carpeta raiz del script)
  DOTFILES_HOST       Override del hostname para perfiles
USAGE
}

NO_LINT=false
NO_CONFLICTS=false
GUI_MODE="auto" # auto|on|off
JSON=false

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
  --json)
    JSON=true
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

# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

info() { [ "$JSON" = "true" ] && return 0; printf '[INFO] %s\n' "$*"; }
warn() { [ "$JSON" = "true" ] && return 0; printf '[WARN] %s\n' "$*" >&2; }
err() { printf '[ERROR] %s\n' "$*" >&2; }

action() {
  [ "$JSON" = "true" ] && return 0
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

check_tmux_tpm() {
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local tpm="$data_home/tmux/plugins/tpm/tpm"
  if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux: no está instalado (TPM/plugins no aplican)"
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    warn "git: no está instalado (TPM no podrá clonar plugins)"
    return 0
  fi

  if [ -x "$tpm" ]; then
    info "tmux TPM: OK ($tpm)"
    return 0
  fi

  warn "tmux TPM: no encontrado ($tpm)"
  warn "bootstrap instalará TPM/plugins automáticamente (o puedes pasar --skip-tmux-plugins)."
  return 0
}

main() {
  local host
  host="$(resolve_host || true)"
  HOST_NAME="$host"
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
      local -a check_args=()
      if ! command -v shellcheck >/dev/null 2>&1; then
        warn "shellcheck no está instalado; lint será parcial."
        check_args+=("--no-shellcheck")
      fi
      if ! command -v shfmt >/dev/null 2>&1; then
        warn "shfmt no está instalado; se omite verificación de formato."
        check_args+=("--no-shfmt")
      fi

      action LINT "Corriendo scripts/check.sh"
      "$REPO_DIR/scripts/check.sh" "${check_args[@]}"
    else
      warn "No existe scripts/check.sh (omito lint)"
    fi
  fi

  # Chequeos extra: tmux plugins
  local have_tmux=false
  local p
  for p in "${home_pkgs[@]}"; do
    if [ "$p" = "tmux" ]; then
      have_tmux=true
      break
    fi
  done

  if [ "$have_tmux" = "true" ]; then
    action TMUX "Verificando TPM"
    check_tmux_tpm || return 1
  fi

  info "Doctor OK: listo para bootstrap/rollback."
}

main
status=$?

if [ "$JSON" = "true" ]; then
  printf '{"ok":%s,"repo":"%s","stow":"%s","host":"%s","wsl":%s,"gui_mode":"%s"}\n' \
    "$( [ "$status" -eq 0 ] && printf 'true' || printf 'false' )" \
    "${REPO_DIR//"/\\"}" \
    "${STOW_DIR//"/\\"}" \
    "${HOST_NAME//"/\\"}" \
    "$( is_wsl && printf 'true' || printf 'false' )" \
    "$GUI_MODE"
fi

exit "$status"
