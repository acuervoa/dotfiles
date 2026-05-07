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

Ejemplos:
  scripts/rollback.sh --dry-run latest
  scripts/rollback.sh --manifest .manifests/<timestamp>.manifest
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

# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs
ensure_compat_links

SELECTED_INPUT="${1:-latest}"

MANIFEST_USED=false

pick_manifest() {
  if [ -n "$MANIFEST_PATH" ]; then
    [ -f "$MANIFEST_PATH" ] || {
      printf '[ERROR] Manifest no encontrado: %s\n' "$MANIFEST_PATH" >&2
      exit 1
    }
    printf '%s' "$MANIFEST_PATH"
    return 0
  fi

  manifest_path_for_input "$SELECTED_INPUT"
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

  local -a home_pkgs=()
  local -a config_pkgs=()
  local backup_dir_abs="" backup_dir_rel="" backup_dir_state_rel="" backup_needed=""

  local manifest=""
  if manifest="$(pick_manifest 2>/dev/null)"; then
    MANIFEST_USED=true
    info "Usando manifest: $manifest"

    manifest_get_array "$manifest" home_pkgs home_pkgs
    manifest_get_array "$manifest" config_pkgs config_pkgs
    manifest_get_string "$manifest" backup_dir_abs backup_dir_abs
    manifest_get_string "$manifest" backup_dir_rel backup_dir_rel
    manifest_get_string "$manifest" backup_dir_state_rel backup_dir_state_rel
    manifest_get_bool "$manifest" backup_needed backup_needed

    if [ "$GUI_MODE" != "auto" ]; then
      warn "Se encontró manifest: ignorando --core-only/--gui (usa el manifest)."
    fi
  else
    warn "No se encontró manifest; usando perfil de host (o default)."

    load_host_packages_profile

    home_pkgs=("${HOME_PKGS[@]}")
    build_config_packages "$GUI_MODE" config_pkgs

    backup_dir_rel=""
  fi

  local selected_backup=""

  if [ "$MANIFEST_USED" = "true" ]; then
    if [ -n "${backup_dir_abs:-}" ] && [ -d "$backup_dir_abs" ]; then
      selected_backup="$backup_dir_abs"
    elif [ -n "${backup_dir_state_rel:-}" ] && [ -d "$BACKUP_BASE/$backup_dir_state_rel" ]; then
      selected_backup="$BACKUP_BASE/$backup_dir_state_rel"
    elif [ -n "${backup_dir_rel:-}" ] && [ -d "$REPO_DIR/$backup_dir_rel" ]; then
      selected_backup="$REPO_DIR/$backup_dir_rel"
    else
      case "${backup_needed:-legacy}" in
        false)
          selected_backup=""
          ;;
        true)
          warn "Manifest indica backup_needed=true pero no existe el backup: ${backup_dir_abs:-${backup_dir_rel:-<vacío>}}"
          selected_backup=""
          ;;
        legacy)
          warn "Manifest legacy sin backup_needed; por seguridad no hay fallback automático a backups antiguos."
          if [ "${DOTFILES_ROLLBACK_FALLBACK:-0}" = "1" ] && [ "$SELECTED_INPUT" = "latest" ]; then
            selected_backup="$(backup_path_for_input "$SELECTED_INPUT" 2>/dev/null || true)"
          fi
          ;;
      esac
    fi
  else
    if [ -n "${backup_dir_rel:-}" ] && [ -d "$REPO_DIR/$backup_dir_rel" ]; then
      selected_backup="$REPO_DIR/$backup_dir_rel"
    else
      selected_backup="$(backup_path_for_input "$SELECTED_INPUT" 2>/dev/null || true)"
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
    run_stow_package "$pkg" "$HOME" -D "Desinstalando '$pkg' de $HOME" || continue
  done

  # Paquete meta (perfiles de host)
  if [ -d "$STOW_DIR/dotfiles" ]; then
    run_stow_package "dotfiles" "$HOME" -D "Desinstalando 'dotfiles' (bajo $HOME/.config)"
  fi

  run_cmd mkdir -p "$HOME/.config"
  for pkg in "${config_pkgs[@]}"; do
    run_stow_package "$pkg" "$HOME" -D "Desinstalando '$pkg' (bajo $HOME/.config)" || continue
    # Los paquetes en stow/* suelen incluir el prefijo `.config/`, por lo que el
    # target correcto para stow es $HOME (igual que en bootstrap.sh).
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
