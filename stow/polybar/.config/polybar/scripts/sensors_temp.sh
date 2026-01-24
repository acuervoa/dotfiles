#!/usr/bin/env bash
set -euo pipefail

command -v sensors >/dev/null 2>&1 || exit 0

# Preferir JSON si existe y jq está disponible
if sensors -j >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    temp="$(sensors -j | jq -r '
    .. | objects | to_entries[]? |
    select(.key|test("temp[0-9]+_input")) |
    .value | numbers? ' 2>/dev/null | head -n1 || true)"
else
    # Fallback parse texto: primera temperatura tipo "+45.0°C"
    temp="$(sensors 2>/dev/null | awk '
    match($0, /\+[0-9]+(\.[0-9]+)?°C/) { print substr($0, RSTART+1, RLENGTH-3); exit }' || true)"
fi

[[ -n "${temp:-}" ]] || exit 0
printf 'CPU %s°C\n' "$temp"
