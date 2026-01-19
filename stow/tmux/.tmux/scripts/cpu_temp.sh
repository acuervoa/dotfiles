#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# 1) Try lm-sensors output (más fiable si está configurado)
if command -v sensors >/dev/null 2>&1; then
  # Busca primero Tctl (AMD) o "Package id 0" (Intel). Si no, la primera coincidencia de "+NN.N°C".
  out=$(sensors 2>/dev/null | awk '
    /Tctl:/               { if (match($0, /\+([0-9]+(\.[0-9])?)°C/, a)) {print a[1]; exit} }
    /Package id 0:/       { if (match($0, /\+([0-9]+(\.[0-9])?)°C/, a)) {print a[1]; exit} }
    /\+([0-9]+(\.[0-9])?)°C/ { if (match($0, /\+([0-9]+(\.[0-9])?)°C/, a)) {print a[1]; exit} }
  ')
  if [[ -n "${out:-}" ]]; then
    printf "%s°C\n" "$out"
    exit 0
  fi
fi

# 2) Fallback: sysfs (millicelsius)
best=""
for z in /sys/class/thermal/thermal_zone*/temp; do
  [[ -r "$z" ]] || continue
  v=$(<"$z") || v=""
  [[ -n "$v" ]] || continue
  # Normaliza millicelsius → °C (con 1 decimal)
  c=$(awk -v m="$v" 'BEGIN{printf "%.1f", m/1000.0}')
  # Guarda el mayor (peor caso)
  if [[ -z "$best" ]]; then best="$c"; else
    awk -v a="$best" -v b="$c" 'BEGIN{if (b>a) print b; else print a}' >/tmp/.tmpmax
    best=$(</tmp/.tmpmax)
  fi
done

if [[ -n "$best" ]]; then
  printf "%s°C\n" "$best"
else
  printf "--°C\n"
fi

