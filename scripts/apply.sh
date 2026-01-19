#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/apply.sh [opciones]

Workflow recomendado:
- Corre scripts/doctor.sh (checks read-only)
- Corre scripts/bootstrap.sh --dry-run (plan)
- Pide una sola confirmacion
- Ejecuta scripts/bootstrap.sh -y (apply real)

Opciones:
  --dry-run            Solo doctor + bootstrap --dry-run (no aplica cambios)
  -y, --yes            No pedir confirmacion (igual corre doctor + dry-run)
  --core-only          Modo core (omite GUI)
  --gui                Fuerza incluir GUI
  --init-submodules    Pasa --init-submodules a bootstrap
  --no-lint            Pasa --no-lint a doctor
  --no-conflicts       Pasa --no-conflicts a doctor
  -h, --help           Muestra esta ayuda

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raiz del script)
  DOTFILES_HOST        Override del hostname para perfiles
USAGE
}

DRY_RUN=false
ASSUME_YES=false
NO_LINT=false
NO_CONFLICTS=false
INIT_SUBMODULES=false
GUI_MODE="auto" # auto|on|off

while (($# > 0)); do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    ;;
  -y | --yes)
    ASSUME_YES=true
    ;;
  --no-lint)
    NO_LINT=true
    ;;
  --no-conflicts)
    NO_CONFLICTS=true
    ;;
  --init-submodules)
    INIT_SUBMODULES=true
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
REPO_DIR="${REPO_DIR/#\~/$HOME}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift
  printf '[%s] %s\n' "$kind" "$*"
}

confirm() {
  local msg="${1:-Aplicar cambios? [y/N] }" ans

  if [ "$ASSUME_YES" = "true" ]; then
    return 0
  fi

  printf '%s' "$msg" >&2
  read -r ans
  case "$ans" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

main() {
  local -a doctor_args=()
  local -a bootstrap_args=()

  if [ "$NO_LINT" = "true" ]; then
    doctor_args+=(--no-lint)
  fi
  if [ "$NO_CONFLICTS" = "true" ]; then
    doctor_args+=(--no-conflicts)
  fi

  case "$GUI_MODE" in
  off)
    doctor_args+=(--core-only)
    bootstrap_args+=(--core-only)
    ;;
  on)
    doctor_args+=(--gui)
    bootstrap_args+=(--gui)
    ;;
  auto) ;;
  *) ;;
  esac

  if [ "$INIT_SUBMODULES" = "true" ]; then
    bootstrap_args+=(--init-submodules)
  fi

  local doctor="$REPO_DIR/scripts/doctor.sh"
  local bootstrap="$REPO_DIR/scripts/bootstrap.sh"

  if [ ! -f "$doctor" ]; then
    warn "No existe: $doctor"
    return 1
  fi
  if [ ! -f "$bootstrap" ]; then
    warn "No existe: $bootstrap"
    return 1
  fi

  action DOCTOR "Ejecutando doctor"
  bash "$doctor" "${doctor_args[@]}"

  action PLAN "Ejecutando bootstrap --dry-run"
  bash "$bootstrap" --dry-run "${bootstrap_args[@]}"

  if [ "$DRY_RUN" = "true" ]; then
    info "Dry-run completado (no se aplicaron cambios)."
    return 0
  fi

  confirm || {
    info "Operacion cancelada."
    return 0
  }

  action APPLY "Ejecutando bootstrap (apply real)"
  bash "$bootstrap" -y "${bootstrap_args[@]}"
}

main
