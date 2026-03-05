#!/usr/bin/env bash
set -euo pipefail

usage() {
        cat <<'USAGE'
Uso: bootstrap.sh [opciones]

Opciones:
  -n, --dry-run        Muestra las acciones sin modificar nada.
  -h, --help           Muestra esta ayuda.

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raíz del script).
USAGE
}

DRY_RUN=false
USER_REPO=""

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
        --repo)
                if (($# < 2)); then
                        echo "[ERROR] --repo requiere una ruta" >&2
                        exit 1
                fi
                USER_REPO="$2"
                shift 2
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
REPO_DIR="${USER_REPO:-${DOTFILES:-$DEFAULT_REPO}}"
REPO_DIR="${REPO_DIR/#\~/$HOME}" # expandir ~ inicial

if [[ ! -d "$REPO_DIR" ]]; then
        echo "[ERROR] Repo no encontrado en: $REPO_DIR" >&2
        exit 1
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_BASE="$REPO_DIR/.backups"
MANIFEST_DIR="$REPO_DIR/.manifests"
BACKUP_DIR=""
MANIFEST_FILE="$MANIFEST_DIR/$TIMESTAMP.manifest"
MANIFEST_READY=false

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
action() {
        local kind="$1"; shift
        if $DRY_RUN; then
                printf '[DRY-RUN][%s] %s\n' "$kind" "$*"
        else
                printf '[%s] %s\n' "$kind" "$*"
        fi
}

run_cmd() {
        if $DRY_RUN; then
                return 0
        fi
        "$@"
}

ensure_backup_dir() {
        if [[ -n "$BACKUP_DIR" ]]; then
                return
        fi
        BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
        action "BACKUP" "Creando directorio en $BACKUP_DIR"
        run_cmd mkdir -p "$BACKUP_DIR"
}

ensure_manifest_file() {
        if $DRY_RUN || $MANIFEST_READY; then
                return
        fi
        mkdir -p "$MANIFEST_DIR"
        : >"$MANIFEST_FILE"
        MANIFEST_READY=true
}

record_manifest() {
        local line="$1"
        if $DRY_RUN; then
                return
        fi
        ensure_manifest_file
        printf '%s\n' "$line" >>"$MANIFEST_FILE"
}

link_item() {
        local rel_path="$1"
        local target_rel="$2"
        local src="$REPO_DIR/$rel_path"
        local dest="$HOME/$target_rel"

        if [[ ! -e "$src" && ! -d "$src" ]]; then
                warn "Origen no existe: $src (saltando)"
                return
        fi

        if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
                action "SKIP" "$dest ya apunta a $src"
                return
        fi

        if [[ -e "$dest" || -L "$dest" ]]; then
                ensure_backup_dir
                local backup_dest="$BACKUP_DIR/$target_rel"
                action "MOVE" "Guardando $dest en $backup_dest"
                run_cmd mkdir -p "$(dirname "$backup_dest")"
                run_cmd mv "$dest" "$backup_dest"
        fi

        run_cmd mkdir -p "$(dirname "$dest")"
        action "LINK" "$dest -> $src"
        run_cmd ln -s "$src" "$dest"
        record_manifest "LINK $src -> $dest"
}

HOME_ITEMS=(
        "bash/bashrc:.bashrc"
        "bash/bash_profile:.bash_profile"
        "bash/profile:.profile"
        "bash/xprofile:.xprofile"
        "bash/bash_aliases:.bash_aliases"
        "bash/bash_functions:.bash_functions"
        "bash/bash_lib:.bash_lib"
        "git/gitalias:.gitalias"
        "git/gitconfig:.gitconfig"
        "git/git-hooks:.git-hooks"
        "tmux/tmux.conf:.tmux.conf"
        "tmux/tmux:.tmux"
        "vim/vimrc:.vimrc"
        "vim/vim:.vim"
)

CONFIG_ITEMS=(atuin blesh dunst i3 kitty lazygit mise nvim picom polybar rofi yazi)

main() {
        info "Repo de dotfiles: $REPO_DIR"
        if $DRY_RUN; then
                info "Modo simulación activo (no se aplicarán cambios)"
        fi
        echo

        for entry in "${HOME_ITEMS[@]}"; do
                IFS=":" read -r rel target <<<"$entry"
                link_item "$rel" "$target"
        done

        for pkg in "${CONFIG_ITEMS[@]}"; do
                link_item "config/$pkg" ".config/$pkg"
        done

        echo
        if [[ -n "$BACKUP_DIR" ]]; then
                info "Copias guardadas en: $BACKUP_DIR"
        elif $DRY_RUN; then
                info "No se crearían backups (no hay colisiones detectadas)."
        else
                info "No fue necesario crear backups."
        fi

        if $DRY_RUN; then
                info "Manifest simulado: $MANIFEST_FILE"
        elif $MANIFEST_READY; then
                info "Manifest generado: $MANIFEST_FILE"
        else
                info "No se generó manifest (sin enlaces nuevos)."
        fi

        info "Instalación de dotfiles completada."
}

main
