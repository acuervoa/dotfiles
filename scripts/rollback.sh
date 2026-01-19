#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/rollback.sh [opciones] [latest|TIMESTAMP]

Desinstala paquetes stow y restaura el backup correspondiente (si existe).

Selección:
- `latest` (default): usa el manifest más reciente en `.manifests/` si existe;
  si no, usa el backup más reciente en `.backups/`.
- `TIMESTAMP`: usa `.manifests/<TIMESTAMP>.manifest` (si existe) y/o
  `.backups/<TIMESTAMP>/`.

Opciones:
  -n, --dry-run          Muestra acciones sin modificar nada
  -y, --yes              No pedir confirmación
  --core-only            (sin manifest) omite paquetes GUI
  --gui                  (sin manifest) fuerza incluir paquetes GUI
  --manifest <ruta>      Usar un manifest específico
  -h, --help             Muestra esta ayuda

Variables de entorno:
  DOTFILES               Ruta al repo (por defecto, carpeta raíz del script)
USAGE
}

DRY_RUN=false
ASSUME_YES=false
MANIFEST_PATH=""
GUI_MODE="auto" # auto|on|off

while (($# > 0)); do
  case "$1" in
  -n | --dry-run)
    DRY_RUN=true
    ;;
  -y | --yes)
    ASSUME_YES=true
    ;;
  --core-only)
    GUI_MODE="off"
    ;;
  --gui)
    GUI_MODE="on"
    ;;
  --manifest)
    shift
    MANIFEST_PATH="${1:-}"
    [ -n "$MANIFEST_PATH" ] || { printf '[ERROR] --manifest requiere ruta\n' >&2; exit 1; }
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    break
    ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="${DOTFILES:-$DEFAULT_REPO}"
REPO_DIR="${REPO_DIR/#\~/$HOME}"
STOW_DIR="$REPO_DIR/stow"
BACKUP_BASE="$REPO_DIR/.backups"
MANIFEST_DIR="$REPO_DIR/.manifests"

SELECTED_INPUT="${1:-latest}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift

  if [ "$DRY_RUN" = "true" ]; then
    printf '[DRY-RUN][%s] %s\n' "$kind" "$*"
  else
    printf '[%s] %s\n' "$kind" "$*"
  fi
}

run_cmd() {
  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi
  "$@"
}

confirm() {
  local msg="${1:-¿Continuar? [y/N] }" ans

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

require_cmd() {
  local c
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      printf '[ERROR] Este script requiere %s instalado.\n' "$c" >&2
      exit 1
    fi
  done
}

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] && return 0
  [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version && return 0
  return 1
}

find_latest_dir() {
  local base="$1"
  [ -d "$base" ] || return 1

  local latest
  latest="$(find "$base" -mindepth 1 -maxdepth 1 -printf '%f\n' 2>/dev/null | sort | tail -n 1)" || true
  [ -n "$latest" ] || return 1

  printf '%s/%s' "$base" "$latest"
}

pick_manifest() {
  if [ -n "$MANIFEST_PATH" ]; then
    [ -f "$MANIFEST_PATH" ] || {
      printf '[ERROR] Manifest no encontrado: %s\n' "$MANIFEST_PATH" >&2
      exit 1
    }
    printf '%s' "$MANIFEST_PATH"
    return 0
  fi

  if [ "$SELECTED_INPUT" = "latest" ]; then
    find_latest_dir "$MANIFEST_DIR" || return 1
    return 0
  fi

  local candidate="$MANIFEST_DIR/$SELECTED_INPUT.manifest"
  [ -f "$candidate" ] || return 1
  printf '%s' "$candidate"
}

load_manifest() {
  local manifest="$1"
  # shellcheck disable=SC1090
  source "$manifest"
}

main() {
  require_cmd stow
  require_cmd rsync

  [ -d "$REPO_DIR" ] || {
    printf '[ERROR] Repo no encontrado en: %s\n' "$REPO_DIR" >&2
    exit 1
  }
  [ -d "$STOW_DIR" ] || {
    printf '[ERROR] Directorio stow no encontrado en: %s\n' "$STOW_DIR" >&2
    exit 1
  }

  local manifest=""
  if manifest="$(pick_manifest 2>/dev/null)"; then
    info "Usando manifest: $manifest"
    load_manifest "$manifest"

    if [ "$GUI_MODE" != "auto" ]; then
      warn "Se encontró manifest: ignorando --core-only/--gui (usa el manifest)."
    fi
  else
    warn "No se encontró manifest; usando listas por defecto."

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

    home_pkgs=(bash git tmux vim)

    local -a config_core_pkgs=(atuin blesh lazygit mise nvim yazi)
    local -a config_gui_pkgs=(dunst i3 kitty picom polybar rofi)

    config_pkgs=("${config_core_pkgs[@]}")
    if [ "$include_gui" = "true" ]; then
      config_pkgs+=("${config_gui_pkgs[@]}")
    fi

    backup_dir_rel=""
  fi

  local selected_backup=""

  if [ -n "${backup_dir_rel:-}" ] && [ -d "$REPO_DIR/$backup_dir_rel" ]; then
    selected_backup="$REPO_DIR/$backup_dir_rel"
  elif [ "$SELECTED_INPUT" = "latest" ]; then
    selected_backup="$(find_latest_dir "$BACKUP_BASE" 2>/dev/null || true)"
  else
    if [ -d "$BACKUP_BASE/$SELECTED_INPUT" ]; then
      selected_backup="$BACKUP_BASE/$SELECTED_INPUT"
    fi
  fi

  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"
  info "Target HOME: $HOME"
  info "Target CONFIG: $HOME/.config"

  if [ -n "$selected_backup" ]; then
    info "Backup seleccionado: $selected_backup"
  else
    warn "No hay backup para restaurar (solo se desinstalarán symlinks)."
  fi

  echo
  warn "Esto eliminará symlinks de stow en $HOME y $HOME/.config"
  if [ "$DRY_RUN" != "true" ]; then
    confirm '¿Continuar con el rollback? [y/N] ' || {
      info 'Operación cancelada.'
      exit 0
    }
  fi

  local pkg
  for pkg in "${home_pkgs[@]}"; do
    if [ ! -d "$STOW_DIR/$pkg" ]; then
      warn "Paquete stow inexistente (omito): $pkg"
      continue
    fi
    action STOW "Desinstalando '$pkg' de $HOME"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -D "$pkg"
  done

  run_cmd mkdir -p "$HOME/.config"
  for pkg in "${config_pkgs[@]}"; do
    if [ ! -d "$STOW_DIR/$pkg" ]; then
      warn "Paquete stow inexistente (omito): $pkg"
      continue
    fi
    action STOW "Desinstalando '$pkg' de $HOME/.config"
    run_cmd stow -d "$STOW_DIR" -t "$HOME/.config" -D "$pkg"
  done

  if [ -n "$selected_backup" ]; then
    local conflict_dir
    conflict_dir="$HOME/.dotfiles_rollback_conflicts_$(date +%Y%m%d_%H%M%S)"

    action RSYNC "Restaurando backup -> $HOME (conflictos en $conflict_dir)"
    run_cmd mkdir -p "$conflict_dir"

    run_cmd rsync -a --backup --backup-dir="$conflict_dir" "$selected_backup"/ "$HOME"/

    info "Rollback completado."
    info "Backup restaurado: $selected_backup"
    info "Conflictos guardados: $conflict_dir"
  else
    info "Rollback completado (sin restauración de backup)."
  fi
}

main
