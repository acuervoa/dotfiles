#!/usr/bin/env bash
set -euo pipefail

# Rofi ya forma parte del lanzador de i3 y permite aceptar/cancelar sin ratón.
choice=$(printf '%s\n' 'Cerrar' 'Cancelar' |
  rofi -dmenu -i -no-custom -lines 2 \
    -p '¿Cerrar ventana?' \
    -mesg 'Enter: cerrar · Escape: cancelar') || exit 0

if [ "$choice" = 'Cerrar' ]; then
  i3-msg kill >/dev/null
fi
