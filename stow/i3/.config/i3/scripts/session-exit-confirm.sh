#!/usr/bin/env bash

set -euo pipefail

exec i3-nagbar \
    -t warning \
    -m '¿Quieres salir de i3?' \
    -B 'Sí, salir' \
    "$HOME/.config/i3/scripts/session-exit.sh"
