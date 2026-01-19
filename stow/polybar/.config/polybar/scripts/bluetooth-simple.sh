#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if ! bluetoothctl show | awk -F': ' '/Powered:/ {print $2}' | grep -qi '^yes$'; then
    echo ""
    exit 0
fi

addr="$(bluetoothctl devices Connected | awk '{print $2}' | head -n1  || true)"
if [[ -z "${addr:-}" ]]; then
    echo ""
    exit 0
fi

name="$(bluetoothctl info "$addr" 2>/dev/null | awk -F': ' '/^Name:/ {print $2; exit}')"
if [[ -n "${name:-}" ]]; then
    echo "  ${name}"
else
    echo "  "
fi
