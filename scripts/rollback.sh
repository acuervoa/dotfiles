#!/usr/bin/env bash
set -euo pipefail

usage() {
        cat <<'USAGE'
Uso: rollback.sh [opciones] [DIRECTORIO|latest]

Sin argumentos o con "latest", restaura el backup más reciente.
Puedes pasar un directorio absoluto o uno relativo a:
  - $DOTFILES/.backups
  - $HOME

Opciones:
  --manifest RUTA   Ruta al manifest a usar para limpiar symlinks (por defecto
                    se intenta asociar el manifest por timestamp del backup).

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

POSITIONAL=()
MANIFEST_OVERRIDE=""

while (($# > 0)); do
        case "$1" in
        -h | --help)
                usage
                exit 0
                ;;
        --manifest)
                if (($# < 2)); then
                        echo "[ERROR] --manifest requiere una ruta" >&2
                        exit 1
                fi
                MANIFEST_OVERRIDE="$2"
                shift 2
                ;;
        --)
                shift
                break
                ;;
        -*)
                echo "[ERROR] Opción no reconocida: $1" >&2
                usage >&2
                exit 1
                ;;
        *)
                POSITIONAL+=("$1")
                shift
                ;;
        esac
done

if ((${#POSITIONAL[@]} > 1)); then
        echo "[ERROR] Solo se admite un argumento de directorio." >&2
        usage >&2
        exit 1
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

SELECTED_INPUT="${POSITIONAL[0]-}"
SELECTED_DIR="$(resolve_input_path "$SELECTED_INPUT")"
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

resolve_manifest_path() {
        local override="$1"
        local base_dir="$2"

        if [[ -n "$override" ]]; then
                local path="$override"
                path="${path/#\~/$HOME}"
                if [[ "$path" != /* ]]; then
                        path="$REPO_DIR/$path"
                fi
                echo "$path"
                return
        fi

        local backup_name
        backup_name="$(basename "$base_dir")"
        if [[ "$backup_name" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
                echo "$REPO_DIR/.manifests/$backup_name.manifest"
        else
                echo ""
        fi
}

remove_links_from_manifest() {
        local manifest="$1"

        if [[ -z "$manifest" ]]; then
                echo "[WARN] No se pudo determinar manifest asociado; se omite limpieza de symlinks." >&2
                return
        fi

        if [[ ! -f "$manifest" ]]; then
                echo "[WARN] Manifest no encontrado: $manifest" >&2
                echo "[WARN] Se omite la eliminación de symlinks; puede que el rollback deje enlaces antiguos." >&2
                return
        fi

        echo "[INFO] Usando manifest: $manifest"
        local pattern='^LINK[[:space:]]+(.*)[[:space:]]+->[[:space:]]+(.*)$'
        while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                if [[ $line =~ $pattern ]]; then
                        local src="${BASH_REMATCH[1]}"
                        local dest="${BASH_REMATCH[2]}"
                        if [[ -L "$dest" ]]; then
                                local current
                                current="$(readlink "$dest")"
                                if [[ "$current" == "$src" ]]; then
                                        echo "[INFO] Eliminando symlink: $dest"
                                        rm "$dest"
                                else
                                        echo "[WARN] $dest es un symlink pero apunta a '$current' (esperado '$src'); no se toca." >&2
                                fi
                        elif [[ -e "$dest" ]]; then
                                echo "[WARN] $dest existe y no es symlink; se mantiene." >&2
                        fi
                fi
        done <"$manifest"
}

MANIFEST_PATH="$(resolve_manifest_path "$MANIFEST_OVERRIDE" "$SELECTED_DIR")"

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

remove_links_from_manifest "$MANIFEST_PATH"

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
