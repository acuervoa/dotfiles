#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Uso: bootstrap_stow.sh [opciones]

Opciones:
  -n, --dry-run        Muestra las acciones sin modificar nada.
  -h, --help           Muestra esta ayuda.

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raíz del script).
USAGE
}

DRY_RUN=false
while (($# > 0)); do
    case "$1" in
    -n | --dry-run) 
        DRY_RUN=true
        shift
        ;; 
    -h | --help) 
        usage
        exit 0
        ;; 
    *)
        echo "[ERROR] Opción no reconocida: $1" >&2
        usage >&2
        exit 1
        ;; 
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="${DOTFILES:-$DEFAULT_REPO}"
REPO_DIR="${REPO_DIR/#\~/$HOME}"
STOW_DIR="$REPO_DIR/stow"

if ! command -v stow >/dev/null 2>&1; then
    echo "[ERROR] Este script requiere 'stow' instalado." >&2
    exit 1
fi

if [[ ! -d "$REPO_DIR" ]]; then
    echo "[ERROR] Repo no encontrado en: $REPO_DIR" >&2
    exit 1
fi

if [[ ! -d "$STOW_DIR" ]]; then
    echo "[ERROR] Directorio 'stow' no encontrado en: $STOW_DIR" >&2
    exit 1
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$REPO_DIR/.backups/$TIMESTAMP"

# Paquetes que van a $HOME
HOME_PKGS=(bash git tmux vim)
# Paquetes que van a $HOME/.config
CONFIG_PKGS=(atuin blesh dunst i3 kitty lazygit mise nvim picom polybar rofi yazi)

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*"; }
action() {
    local kind="$1"; shift
    if $DRY_RUN;
    then
        printf "[DRY-RUN][%s] %s\n" "$kind" "$*"
    else
        printf "[%s] %s\n" "$kind" "$*"
    fi
}

run_cmd() {
    if $DRY_RUN;
    then
        return 0
    fi
    "$@"
}

handle_conflicts() {
    local pkg="$1"
    local target_dir="$2"
    
    info "Comprobando conflictos para el paquete '$pkg' en $target_dir..."
    
    # `stow -n` nos dice qué haría. Buscamos las líneas de conflicto.
    # El formato es: "existing file is not a symlink: ..."
    conflicts=$(stow -d "$STOW_DIR" -t "$target_dir" -nS "$pkg" 2>&1 | grep 'CONFLICT: existing target is not a symlink:' || true)
    
    if [[ -z "$conflicts" ]]; then
        info "No se encontraron conflictos para '$pkg'."
        return
    fi
    
    warn "Conflictos detectados para '$pkg'. Se creará un backup."
    action "BACKUP" "Creando directorio de backup en $BACKUP_DIR"
    run_cmd mkdir -p "$BACKUP_DIR"
    
    echo "$conflicts" | while read -r line; do
        # Extraemos la ruta del fichero en conflicto
        file_path=$(echo "$line" | sed -e 's/.*CONFLICT: existing target is not a symlink: //')
        
        # Si el fichero está en .config, la ruta es relativa a .config
        full_path="$target_dir/$file_path"
        
        action "MOVE" "Moviendo $full_path a $BACKUP_DIR/$file_path"
        run_cmd mkdir -p "$BACKUP_DIR/$(dirname "$file_path")"
        run_cmd mv "$full_path" "$BACKUP_DIR/$file_path"
    done
}

main() {
    info "Repo de dotfiles: $REPO_DIR"
    info "Directorio de stow: $STOW_DIR"
    if $DRY_RUN;
    then
        info "Modo simulación activo (no se aplicarán cambios)"
    fi
    echo

    # Procesar paquetes de $HOME
    for pkg in "${HOME_PKGS[@]}"; do
        handle_conflicts "$pkg" "$HOME"
        action "STOW" "Instalando paquete '$pkg' en $HOME"
        run_cmd stow -d "$STOW_DIR" -t "$HOME" -S "$pkg"
    done
    
    # Procesar paquetes de $HOME/.config
    mkdir -p "$HOME/.config"
    for pkg in "${CONFIG_PKGS[@]}"; do
        handle_conflicts "$pkg" "$HOME/.config"
        action "STOW" "Instalando paquete '$pkg' en $HOME/.config"
        run_cmd stow -d "$STOW_DIR" -t "$HOME/.config" -S "$pkg"
    done

    echo
    info "Bootstrap con stow completado."
}

main
