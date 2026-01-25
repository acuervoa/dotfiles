#!/usr/bin/env bash
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$cache_dir"
log_file="$cache_dir/system-update.log"

helper=""
if have yay; then
    helper="yay"
elif have paru; then
    helper="paru"
else
    echo "[actualizar-sistema] No encuentro AUR helper (yay/paru)." >&2
    exit 1
fi

notify() {
    local title="$1" body="$2" icon="${3:-system-software-update}"
    have notify-send || return 0
    notify-send "$title" "$body" -i "$icon" || true
}

notify "Actualización del sistema" "Iniciando actualización con $helper…" "system-software-update"

extra_flags=()
if [ "${YAY_NOCONFIRM:-}" = "1" ]; then extra_flags+=(--noconfirm); fi

set +e
"$helper" -Syu --sudoloop "${extra_flags[@]}" 2>&1 | tee "$log_file"
status=${PIPESTATUS[0]}
set -e

if [ "$status" -eq 0 ]; then
    notify "Actualización completa" "El sistema se actualizó correctamente." "checkbox-checked"
else
    notify "Error en la actualización" "Revisa el log: $log_file" "dialog-error"
fi

exit "$status"
