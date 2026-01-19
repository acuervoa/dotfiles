#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Uso: rollback_stow.sh [opciones] [DIRECTORIO|latest]

Sin argumentos o con "latest", restaura el backup más reciente de .backups/.
Puedes pasar un nombre de directorio que exista dentro de .backups/.

Opciones:
  -h, --help           Muestra esta ayuda.

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raíz del script).
USAGE
}

while (($# > 0)); do
    case "$1" in
    -h | --help) 
        usage
        exit 0
        ;; 
    *)
        break # El resto son argumentos posicionales
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
if ! command -v rsync >/dev/null 2>&1; then
    echo "[ERROR] Este script requiere 'rsync' instalado." >&2
    exit 1
fi

BACKUP_BASE="$REPO_DIR/.backups"
SELECTED_INPUT="${1:-latest}"

find_latest_backup() {
    if [[ ! -d "$BACKUP_BASE" ]]; then
        return 1
    fi
    find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1
}

SELECTED_DIR=""
if [[ "$SELECTED_INPUT" == "latest" ]]; then
    SELECTED_DIR=$(find_latest_backup)
    if [[ -z "$SELECTED_DIR" ]]; then
        echo "[ERROR] No se encontraron backups en $BACKUP_BASE" >&2
        exit 1
    fi
else
    SELECTED_DIR="$BACKUP_BASE/$SELECTED_INPUT"
    if [[ ! -d "$SELECTED_DIR" ]]; then
        echo "[ERROR] Directorio de backup no encontrado: $SELECTED_DIR" >&2
        exit 1
    fi
fi

# Paquetes que van a $HOME
HOME_PKGS=(bash git tmux vim)
# Paquetes que van a $HOME/.config
CONFIG_PKGS=(atuin blesh dunst i3 kitty lazygit mise nvim picom polybar rofi yazi)

info() { printf "[INFO] %s\n" "$*"; }
action() { printf "[ACTION] %s\n" "$*"; }

main() {
    info "Repo de dotfiles: $REPO_DIR"
    info "Directorio de stow: $STOW_DIR"
    echo

    read -r -p "¿Continuar con el rollback? Se eliminarán los symlinks y se restaurará el backup. [y/N] " ans
    case "$ans" in
    [yY][eE][sS] | [yY]) ;; 
    *) 
        info "Operación cancelada."
        exit 0
        ;; 
    esac

    # Desinstalar paquetes de $HOME
    for pkg in "${HOME_PKGS[@]}"; do
        action "Desinstalando paquete '$pkg' de $HOME"
        stow -d "$STOW_DIR" -t "$HOME" -D "$pkg"
    done
    
    # Desinstalar paquetes de $HOME/.config
    for pkg in "${CONFIG_PKGS[@]}"; do
        action "Desinstalando paquete '$pkg' de $HOME/.config"
        stow -d "$STOW_DIR" -t "$HOME/.config" -D "$pkg"
    done

    info "Todos los paquetes de stow han sido desinstalados."
    echo

    if [[ -d "$SELECTED_DIR" ]]; then
        info "Restaurando backup desde: $SELECTED_DIR"
        CONFLICT_DIR="$HOME/.dotfiles_rollback_conflicts_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$CONFLICT_DIR"
        info "Los ficheros actuales que se sobrescriban se guardarán en: $CONFLICT_DIR"
        
        rsync -a \
            --backup \
            --backup-dir="$CONFLICT_DIR" \
            "$SELECTED_DIR"/ \
            "$HOME"/
        
        info "Rollback completado. Ficheros restaurados desde: $SELECTED_DIR"
    else
        info "No se encontró un backup para restaurar. Solo se han eliminado los symlinks."
    fi
}

main
