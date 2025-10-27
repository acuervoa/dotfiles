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
    local manifest_files=()
    local nullglob_was_set=0
    if shopt -q nullglob; then
      nullglob_was_set=1
    fi
    shopt -s nullglob
    manifest_files=("$MANIFEST_ROOT"/*.manifest)
    if ((nullglob_was_set == 0)); then
      shopt -u nullglob
    fi

    if ((${#manifest_files[@]} == 0)); then
      return 2
    fi

    printf '%s\n' "${manifest_files[@]}" | sort | tail -n1
  else
    echo "$MANIFEST_ROOT/$sel.manifest"
  fi
}

if MANIFEST="$(pick_manifest "${1:-latest}")"; then
  :
else
  status=$?
  if ((status == 2)); then
    echo "No se encontraron manifests en $MANIFEST_ROOT" >&2
  fi
  exit "$status"
fi
[[ -f "$MANIFEST" ]] || {
  echo "No existe manifest: $MANIFEST" >&2
  exit 1
}
TS="$(basename "$MANIFEST" .manifest)"
BACKUP_DIR="$BACKUP_ROOT/$TS"
[[ -d "$BACKUP_DIR" ]] || {
  echo "No existe backup dir: $BACKUP_DIR" >&2
  exit 1
}

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
done <"$MANIFEST"

if ((${#PACKAGES[@]})); then
  EXISTING=()
  MISSING=()
  for pkg in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES/config/$pkg" ]]; then
      EXISTING+=("$pkg")
    else
      MISSING+=("$pkg")
    fi
  done

  if ((${#MISSING[@]})); then
    echo "[*] Omitiendo paquetes ausentes: ${MISSING[*]}"
  fi

  if ((${#EXISTING[@]})); then
    if ! command -v stow >/dev/null 2>&1; then
      echo "[!] 'stow' no está instalado. Omitiendo des-stow de paquetes."
    else
      echo "[*] Desstow: ${EXISTING[*]}"
      pushd "$DOTFILES/config" >/dev/null
      stow -v -D -t "$HOME/.config" "${EXISTING[@]}"
      popd >/dev/null
    fi
  else
    echo "[*] No hay paquetes de ~/.config para desstow."
  fi
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
