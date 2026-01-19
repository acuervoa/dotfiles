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

TMPDIR_APPLY=""

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

resolve_host() {
  if [ -n "${DOTFILES_HOST:-}" ]; then
    printf '%s' "$DOTFILES_HOST"
    return 0
  fi

  if command -v hostname >/dev/null 2>&1; then
    hostname -s 2>/dev/null || hostname 2>/dev/null || true
  fi
}

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

  local host
  host="$(resolve_host || true)"
  info "Repo: $REPO_DIR"
  info "Host: ${host:-unknown}"

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

  local tmpdir plan_log apply_log
  tmpdir="$(mktemp -d)"
  TMPDIR_APPLY="$tmpdir"
  plan_log="$tmpdir/bootstrap_dry_run.log"
  apply_log="$tmpdir/bootstrap_apply.log"
  trap 'rm -rf "$TMPDIR_APPLY"' EXIT

  action DOCTOR "Ejecutando doctor"
  bash "$doctor" "${doctor_args[@]}"

  action PLAN "Ejecutando bootstrap --dry-run"
  bash "$bootstrap" --dry-run "${bootstrap_args[@]}" 2>&1 | tee "$plan_log"
  local plan_status=${PIPESTATUS[0]}
  if [ "$plan_status" -ne 0 ]; then
    warn "bootstrap --dry-run fallo (exit=$plan_status)"
    return "$plan_status"
  fi

  local plan_manifest plan_backup
  plan_manifest="$(sed -n 's/^\[INFO\] Manifest: //p' "$plan_log" | tail -n 1)"
  plan_backup="$(sed -n 's/^\[INFO\] Backup: //p' "$plan_log" | tail -n 1)"

  if [ -n "$plan_backup" ]; then
    info "Plan: Backup: $plan_backup"
  fi
  if [ -n "$plan_manifest" ]; then
    info "Plan: Manifest: $plan_manifest"
  fi

  if [ "$DRY_RUN" = "true" ]; then
    info "Dry-run completado (no se aplicaron cambios)."
    return 0
  fi

  confirm || {
    info "Operacion cancelada."
    return 0
  }

  action APPLY "Ejecutando bootstrap (apply real)"
  bash "$bootstrap" -y "${bootstrap_args[@]}" 2>&1 | tee "$apply_log"
  local apply_status=${PIPESTATUS[0]}
  if [ "$apply_status" -ne 0 ]; then
    warn "bootstrap fallo (exit=$apply_status)"
    return "$apply_status"
  fi

  local apply_manifest apply_backup
  apply_manifest="$(sed -n 's/^\[INFO\] Manifest: //p' "$apply_log" | tail -n 1)"
  apply_backup="$(sed -n 's/^\[INFO\] Backup: //p' "$apply_log" | tail -n 1)"

  if [ -n "$apply_manifest" ]; then
    info "Apply: Manifest: $apply_manifest"
  fi
  if [ -n "$apply_backup" ]; then
    info "Apply: Backup: $apply_backup"
  fi

  info "Apply OK."
}

main
