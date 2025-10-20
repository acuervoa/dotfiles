#!/usr/bin/env bash
# Rollback dotfiles — desstow + restaurar backup según manifest
# Uso:
#   ./scripts/rollback.sh [TIMESTAMP|latest]
set -Eeuo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
MANIFEST_ROOT="$DOTFILES/.manifests"
BACKUP_ROOT="$DOTFILES/.backups"

pick_manifest() {
  local sel="$1"
  if [[ "$sel" == "latest" || -z "$sel" ]]; then
    ls -1 "$MANIFEST_ROOT"/*.manifest 2>/dev/null | sort | tail -n1
  else
    echo "$MANIFEST_ROOT/$sel.manifest"
  fi
}

MANIFEST="$(pick_manifest "${1:-latest}")"
[[ -f "$MANIFEST" ]] || { echo "No existe manifest: $MANIFEST" >&2; exit 1; }
TS="$(basename "$MANIFEST" .manifest)"
BACKUP_DIR="$BACKUP_ROOT/$TS"
[[ -d "$BACKUP_DIR" ]] || { echo "No existe backup dir: $BACKUP_DIR" >&2; exit 1; }

echo "[*] Usando manifest: $MANIFEST"
echo "[*] Usando backup  : $BACKUP_DIR"

# 1) Des-stow de los paquetes listados
PACKAGES=()
while read -r line; do
  if [[ "$line" == PACKAGES* ]]; then
    read -r _ rest <<<"$line"
    PACKAGES=($rest)
    break
  fi
done < "$MANIFEST"

if (( ${#PACKAGES[@]} )); then
  echo "[*] Desstow: ${PACKAGES[*]}"
  pushd "$DOTFILES/config" >/dev/null
  stow -v -D -t "$HOME/.config" "${PACKAGES[@]}"
  popd >/dev/null
fi

# 2) Eliminar symlinks creados según manifest
echo "[*] Eliminando symlinks registrados…"
grep '^LINK ' "$MANIFEST" | while read -r _ src _ arrow dest; do
  # línea: LINK SRC -> DEST
  if [[ -L "$dest" ]]; then
    rm -f "$dest"
    echo "  rm $dest"
  fi
done

# 3) Restaurar backup
echo "[*] Restaurando backup sobre \$HOME…"
rsync -a "$BACKUP_DIR"/ "$HOME"/

echo "[*] Rollback completado."
exit 0
