#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/bootstrap.sh [opciones]

Crea symlinks de los paquetes `stow/` hacia `$HOME` y `$HOME/.config`.
Si hay conflictos (targets existentes que no son symlinks), los mueve a
`.backups/<TIMESTAMP>/` antes de crear enlaces.

Opciones:
  -n, --dry-run          Muestra acciones sin modificar nada
  -y, --yes              No pedir confirmación (modo no-interactivo)
  --core-only            Instala solo paquetes no-GUI (útil en WSL/servers)
  --gui                  Fuerza incluir paquetes GUI (desktop)
  --init-submodules      Inicializa submódulos (git) si aplica
  -h, --help             Muestra esta ayuda

Variables de entorno:
  DOTFILES               Ruta al repo (por defecto, carpeta raíz del script)
USAGE
}

DRY_RUN=false
ASSUME_YES=false
INIT_SUBMODULES=false
GUI_MODE="auto" # auto|on|off
BACKUP_NEEDED=false

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
  --init-submodules)
    INIT_SUBMODULES=true
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
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
STOW_DIR="$REPO_DIR/stow"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$REPO_DIR/.backups/$TIMESTAMP"
MANIFEST_DIR="$REPO_DIR/.manifests"
MANIFEST_FILE="$MANIFEST_DIR/$TIMESTAMP.manifest"

# Paquetes que van a $HOME
HOME_PKGS=(bash git tmux vim)

# Paquetes que van a $HOME/.config
# - Separados en core vs GUI para poder soportar WSL/servers.
CONFIG_CORE_PKGS=(atuin blesh lazygit mise nvim yazi)
CONFIG_GUI_PKGS=(dunst i3 kitty picom polybar rofi)
CONFIG_PKGS=("${CONFIG_CORE_PKGS[@]}" "${CONFIG_GUI_PKGS[@]}")

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

write_manifest() {
  action MANIFEST "Escribiendo manifest: $MANIFEST_FILE"

  run_cmd mkdir -p "$MANIFEST_DIR"

  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi

  cat >"$MANIFEST_FILE" <<EOF
# dotfiles manifest (auto-generado)
# timestamp: $TIMESTAMP

timestamp="$TIMESTAMP"
home_pkgs=(${HOME_PKGS[*]})
config_pkgs=(${CONFIG_PKGS[*]})
backup_dir_rel=".backups/$TIMESTAMP"
EOF
}

maybe_init_submodules() {
  if [ "$INIT_SUBMODULES" != "true" ]; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git no está instalado; no puedo inicializar submódulos."
    return 0
  fi

  if [ ! -f "$REPO_DIR/.gitmodules" ]; then
    warn "No existe .gitmodules; omitiendo init de submódulos."
    return 0
  fi

  action GIT "git submodule update --init --recursive"
  run_cmd git -C "$REPO_DIR" submodule update --init --recursive
}

handle_conflicts() {
  local pkg="$1"
  local target_dir="$2"

  info "Comprobando conflictos para '$pkg' en $target_dir..."

  local conflicts
  conflicts="$(
    stow -d "$STOW_DIR" -t "$target_dir" -nS "$pkg" 2>&1 |
      grep -E 'existing target is not (a symlink|owned by stow|a directory|a link nor a directory):' || true
  )"

  if [ -z "$conflicts" ]; then
    return 0
  fi

  BACKUP_NEEDED=true

  warn "Conflictos detectados para '$pkg'. Se creará un backup en $BACKUP_DIR"
  action BACKUP "mkdir -p $BACKUP_DIR"
  run_cmd mkdir -p "$BACKUP_DIR"

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    local file_path
    file_path="$line"
    file_path="${file_path#*CONFLICT: existing target is not a symlink: }"
    file_path="${file_path#*existing target is not owned by stow: }"
    file_path="${file_path#*existing target is not a directory: }"
    file_path="${file_path#*existing target is not a link nor a directory: }"

    local full_path="$target_dir/$file_path"

    action MOVE "Moviendo $full_path -> $BACKUP_DIR/$file_path"
    run_cmd mkdir -p "$BACKUP_DIR/$(dirname -- "$file_path")"
    run_cmd mv -- "$full_path" "$BACKUP_DIR/$file_path"
  done <<<"$conflicts"
}

main() {
  require_cmd stow

  [ -d "$REPO_DIR" ] || {
    printf '[ERROR] Repo no encontrado en: %s\n' "$REPO_DIR" >&2
    exit 1
  }
  [ -d "$STOW_DIR" ] || {
    printf '[ERROR] Directorio stow no encontrado en: %s\n' "$STOW_DIR" >&2
    exit 1
  }

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
    *)
      warn "GUI_MODE inválido: $GUI_MODE (uso auto)"
      include_gui=true
      ;;
    esac
  fi

  CONFIG_PKGS=("${CONFIG_CORE_PKGS[@]}")
  if [ "$include_gui" = "true" ]; then
    CONFIG_PKGS+=("${CONFIG_GUI_PKGS[@]}")
  fi

  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"
  info "Timestamp: $TIMESTAMP"
  if [ "$DRY_RUN" = "true" ]; then
    info "Modo simulación activo (no se aplicarán cambios)"
  fi

  echo
  info "Paquetes -> $HOME: ${HOME_PKGS[*]}"
  info "Paquetes -> $HOME/.config: ${CONFIG_PKGS[*]}"
  echo

  if [ "$DRY_RUN" != "true" ]; then
    warn "Esto modificará $HOME (symlinks) y puede mover ficheros a $BACKUP_DIR"
    confirm '¿Continuar? [y/N] ' || {
      info 'Operación cancelada.'
      exit 0
    }
  fi

  maybe_init_submodules
  write_manifest

  # Procesar paquetes de $HOME
  local pkg
  for pkg in "${HOME_PKGS[@]}"; do
    handle_conflicts "$pkg" "$HOME"
    action STOW "Instalando '$pkg' en $HOME"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -S "$pkg"
  done

  # Procesar paquetes que viven bajo $HOME/.config.
  # Nota: los paquetes en stow/* suelen incluir el prefijo `.config/`, así que
  # el target correcto para stow es $HOME (no $HOME/.config), para evitar acabar
  # con rutas tipo ~/.config/.config/<pkg>.
  run_cmd mkdir -p "$HOME/.config"
  for pkg in "${CONFIG_PKGS[@]}"; do
    handle_conflicts "$pkg" "$HOME"
    action STOW "Instalando '$pkg' (bajo $HOME/.config)"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -S "$pkg"
  done

  echo
  info "Bootstrap completado."
  info "Manifest: $MANIFEST_FILE"
  if [ "$BACKUP_NEEDED" = "true" ]; then
    if [ "$DRY_RUN" = "true" ]; then
      info "Backup: se crearía en $BACKUP_DIR"
    else
      info "Backup: $BACKUP_DIR"
    fi
  else
    info "Backup: no fue necesario"
  fi
}

main
