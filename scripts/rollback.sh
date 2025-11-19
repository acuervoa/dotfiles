#!/usr/bin/env bash
set -euo pipefail

usage() {
        cat <<'USAGE'
Uso: rollback.sh [DIRECTORIO|latest]

Sin argumentos o con "latest", restaura el backup más reciente.
Puedes pasar un directorio absoluto o uno relativo a:
  - $DOTFILES/.backups
  - $HOME

Variables de entorno:
  DOTFILES   Ruta al repo (por defecto, carpeta raíz del script).
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="${DOTFILES:-$DEFAULT_REPO}"
REPO_DIR="${REPO_DIR/#\~/$HOME}"

if [[ ! -d "$REPO_DIR" ]]; then
        echo "[ERROR] Repo no encontrado en: $REPO_DIR" >&2
        exit 1
fi

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
        usage
        exit 0
fi

resolve_input_path() {
        local input="$1"
        if [[ -z "$input" ]]; then
                echo ""
                return
        fi
        case "$input" in
        latest | last)
                echo ""
                return
                ;;
        esac
        if [[ "$input" == /* ]]; then
                echo "$input"
                return
        fi
        if [[ -d "$REPO_DIR/.backups/$input" ]]; then
                echo "$REPO_DIR/.backups/$input"
                return
        fi
        echo "$HOME/$input"
}

find_latest_backup() {
        local candidates=()
        if [[ -d "$REPO_DIR/.backups" ]]; then
                while IFS= read -r path; do
                        candidates+=("$path")
                done < <(find "$REPO_DIR/.backups" -mindepth 1 -maxdepth 1 -type d | sort)
        fi
        while IFS= read -r path; do
                candidates+=("$path")
        done < <(find "$HOME" -mindepth 1 -maxdepth 1 -type d -name '.dotfiles_backup_*' | sort)
        if ((${#candidates[@]} == 0)); then
                return 1
        fi
        printf '%s' "${candidates[-1]}"
}

SELECTED_DIR="$(resolve_input_path "${1-}")"
if [[ -z "$SELECTED_DIR" ]]; then
        if ! latest="$(find_latest_backup)"; then
                echo "[ERROR] No se encontraron directorios de backup en $REPO_DIR/.backups ni en $HOME" >&2
                exit 1
        fi
        SELECTED_DIR="$latest"
fi

if [[ ! -d "$SELECTED_DIR" ]]; then
        echo "[ERROR] Directorio de backup no válido: $SELECTED_DIR" >&2
        exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
        echo "[ERROR] Este script requiere 'rsync' instalado." >&2
        exit 1
fi

echo "[INFO] Directorio de backup seleccionado: $SELECTED_DIR"
echo "[INFO] Se restaurará su contenido sobre $HOME"
echo "[INFO] Los ficheros actuales que se sobrescriban se guardarán en un directorio de conflictos."
echo

read -r -p "¿Continuar con el rollback? [y/N] " ans
case "$ans" in
[yY][eE][sS] | [yY]) ;;
*)
        echo "[INFO] Operación cancelada."
        exit 0
        ;;
esac

CONFLICT_DIR="$HOME/.dotfiles_rollback_conflicts_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$CONFLICT_DIR"

echo "[INFO] Directorio de conflictos: $CONFLICT_DIR"
echo "[INFO] Ejecutando rsync..."
echo

rsync -a \
        --backup \
        --backup-dir="$CONFLICT_DIR" \
        "$SELECTED_DIR"/ \
        "$HOME"/

echo
echo "[OK] Rollback completado."
echo "[INFO] Ficheros restaurados desde: $SELECTED_DIR"
echo "[INFO] Ficheros/symlinks anteriores guardados en: $CONFLICT_DIR"
