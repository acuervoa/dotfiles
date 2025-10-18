#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

read -r L1 L5 L15 _ < /proc/loadavg

# Opcional: normaliza por núcleos (x/cpu)
CPUS=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 1)
norm() { awk -v v="$1" -v n="$2" 'BEGIN{printf "%.2fx", v/n}'; }

printf "%s %s %s (%s)\n" "$L1" "$L5" "$L15" "$(norm "$L1" "$CPUS")"

