#!/usr/bin/env bash
set -euo pipefail

# Evita reinicios múltiples al spamear teclas de volumen
state_dir="${XDG_RUNTIME_DIR:-/tmp}/polybar-hooks"
mkdir -p "$state_dir"
stamp="$state_dir/restart.stamp"

now_ns="$(date +%s%N 2>/dev/null || echo 0)"
last_ns="0"
[[ -f "$stamp" ]] && last_ns="$(cat "$stamp" 2>/dev/null || echo 0)"

# 250ms
min_delta_ns=250000000
if [[ "$now_ns" != 0 ]] && [[ "$last_ns" != 0 ]]; then
    delta=$((now_ns - last_ns))
    if ((delta < min_delta_ns)); then
        exit 0
    fi
fi

echo "$now_ns" >"$stamp" 2>/dev/null || true

# Si no hay polybar, no hacer nada
pgrep -u "$UID" -x polybar >/dev/null 2>&1 || exit 0

# Último recurso: restart (si tus módulos ya actualizan solos, esto se llamará poco)
polybar-msg cmd restart >/dev/null 2>&1 || true
