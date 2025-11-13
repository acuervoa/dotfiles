#!/usr/bin/env bash
# Restaura un backup creado por bootstrap.sh en $HOME
# Usa rsync con --backup para guardar los ficheros/symlinks actuales que se pisen.

set -euo pipefail

HOME_DIR="${HOME:?}"

usage() {
	cat <<EOF
Uso: $(basename "$0") [RUTA_BACKUP]

Sin argumentos, usa el último directorio ~/.dotfiles_backup_*.
Con argumento, puedes pasar una ruta absoluta o relativa al HOME.

Ejemplos:
  $(basename "$0")
  $(basename "$0") ~/.dotfiles_backup_20251113_170000
  $(basename "$0") .dotfiles_backup_20251113_170000
EOF
}

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
	usage
	exit 0
fi

# --- Resolver BACKUP_DIR ---

BACKUP_DIR="${1-}"

if [[ -n "$BACKUP_DIR" ]]; then
	# Si es ruta relativa, asúmela desde $HOME
	if [[ "$BACKUP_DIR" != /* ]]; then
		BACKUP_DIR="$HOME_DIR/$BACKUP_DIR"
	fi
	if [[ ! -d "$BACKUP_DIR" ]]; then
		echo "[ERROR] Directorio de backup no existe: $BACKUP_DIR" >&2
		exit 1
	fi
else
	# Buscar el último ~/.dotfiles_backup_*
	mapfile -t backups < <(find "$HOME_DIR" -maxdepth 1 -type d -name '.dotfiles_backup_*' | sort)
	if ((${#backups[@]} == 0)); then
		echo "[ERROR] No se han encontrado directorios ~/.dotfiles_backup_* en $HOME_DIR" >&2
		exit 1
	fi
	BACKUP_DIR="${backups[-1]}"
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
	echo "[ERROR] $BACKUP_DIR no es un directorio válido." >&2
	exit 1
fi

# --- Comprobar rsync ---

if ! command -v rsync >/dev/null 2>&1; then
	echo "[ERROR] Este script requiere 'rsync' instalado." >&2
	exit 1
fi

echo "[INFO] Directorio de backup seleccionado: $BACKUP_DIR"
echo "[INFO] Se restaurará su contenido sobre $HOME_DIR"
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

# --- Directorio para conflictos (lo que haya ahora y se pise) ---

CONFLICT_DIR="$HOME_DIR/.dotfiles_rollback_conflicts_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$CONFLICT_DIR"

echo "[INFO] Directorio de conflictos: $CONFLICT_DIR"
echo "[INFO] Ejecutando rsync..."
echo

# Nota:
# - "$BACKUP_DIR"/ -> "$HOME_DIR"/ copia el CONTENIDO del backup a $HOME.
# - --backup y --backup-dir mueven lo que exista ahora en $HOME a CONFLICT_DIR antes de sobrescribir.
rsync -a \
	--backup \
	--backup-dir="$CONFLICT_DIR" \
	"$BACKUP_DIR"/ \
	"$HOME_DIR"/

echo
echo "[OK] Rollback completado."
echo "[INFO] Ficheros restaurados desde: $BACKUP_DIR"
echo "[INFO] Ficheros/symlinks anteriores guardados en: $CONFLICT_DIR"
