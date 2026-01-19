#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/update.sh [opciones]

Actualiza el repo y aplica dotfiles con guardrails:
- git fetch
- git pull --ff-only (si hay upstream)
- scripts/apply.sh (doctor + plan + apply)

Opciones:
  --dry-run            No hace pull ni apply real; corre apply en modo --dry-run
  --allow-dirty        Permite correr aun con working tree sucio (no recomendado)
  -y, --yes            Pasa --yes a apply (sin confirmacion)
  --core-only          Pasa --core-only a apply
  --gui                Pasa --gui a apply
  --init-submodules    Pasa --init-submodules a apply
  --no-lint            Pasa --no-lint a apply
  --no-conflicts       Pasa --no-conflicts a apply
  -h, --help           Muestra esta ayuda

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raiz del script)
  DOTFILES_HOST        Override del hostname para perfiles
USAGE
}

DRY_RUN=false
ALLOW_DIRTY=false

APPLY_YES=false
APPLY_CORE_ONLY=false
APPLY_GUI=false
APPLY_INIT_SUBMODULES=false
APPLY_NO_LINT=false
APPLY_NO_CONFLICTS=false

while (($# > 0)); do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    ;;
  --allow-dirty)
    ALLOW_DIRTY=true
    ;;
  -y | --yes)
    APPLY_YES=true
    ;;
  --core-only)
    APPLY_CORE_ONLY=true
    ;;
  --gui)
    APPLY_GUI=true
    ;;
  --init-submodules)
    APPLY_INIT_SUBMODULES=true
    ;;
  --no-lint)
    APPLY_NO_LINT=true
    ;;
  --no-conflicts)
    APPLY_NO_CONFLICTS=true
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
err() { printf '[ERROR] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift
  printf '[%s] %s\n' "$kind" "$*"
}

git_cmd() {
  git -C "$REPO_DIR" "$@"
}

main() {
  [ -d "$REPO_DIR" ] || { err "Repo no encontrado: $REPO_DIR"; return 1; }

  if ! command -v git >/dev/null 2>&1; then
    err "git no esta instalado"
    return 1
  fi

  if ! git_cmd rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    err "No es un repo git: $REPO_DIR"
    return 1
  fi

  local apply="$REPO_DIR/scripts/apply.sh"
  if [ ! -f "$apply" ]; then
    err "No existe: $apply"
    return 1
  fi

  info "Repo: $REPO_DIR"

  local dirty
  dirty="$(git_cmd status --porcelain=v1)" || return 1
  if [ -n "$dirty" ] && [ "$ALLOW_DIRTY" != "true" ]; then
    err "Working tree sucio; abortando. (Usa --allow-dirty si lo quieres forzar)"
    git_cmd status -sb
    return 1
  fi

  action GIT "git fetch --prune"
  if [ "$DRY_RUN" = "true" ]; then
    git_cmd fetch --prune --dry-run
  else
    git_cmd fetch --prune
  fi

  local upstream
  upstream="$(git_cmd rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -n "$upstream" ]; then
    local counts behind ahead
    counts="$(git_cmd rev-list --left-right --count "HEAD...$upstream" 2>/dev/null || true)"
    behind="${counts%% *}"
    ahead="${counts##* }"
    info "Upstream: $upstream (behind=$behind ahead=$ahead)"

    if [ "$DRY_RUN" = "true" ]; then
      action GIT "(dry-run) git pull --ff-only"
      git_cmd pull --ff-only --dry-run
    else
      action GIT "git pull --ff-only"
      git_cmd pull --ff-only
    fi
  else
    warn "No hay upstream configurado; omito pull."
  fi

  local -a apply_args=()
  if [ "$APPLY_YES" = "true" ]; then
    apply_args+=(--yes)
  fi
  if [ "$APPLY_CORE_ONLY" = "true" ]; then
    apply_args+=(--core-only)
  fi
  if [ "$APPLY_GUI" = "true" ]; then
    apply_args+=(--gui)
  fi
  if [ "$APPLY_INIT_SUBMODULES" = "true" ]; then
    apply_args+=(--init-submodules)
  fi
  if [ "$APPLY_NO_LINT" = "true" ]; then
    apply_args+=(--no-lint)
  fi
  if [ "$APPLY_NO_CONFLICTS" = "true" ]; then
    apply_args+=(--no-conflicts)
  fi

  if [ "$DRY_RUN" = "true" ]; then
    action APPLY "apply --dry-run"
    bash "$apply" --dry-run "${apply_args[@]}"
  else
    action APPLY "apply"
    bash "$apply" "${apply_args[@]}"
  fi

  info "Update OK."
}

main
