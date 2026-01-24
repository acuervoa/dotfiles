#!/usr/bin/env bash
set -euo pipefail

# hook_refresh.sh
#
# Mantiene compatibilidad con binds que hacen:
#   <accion> && $refresh_polybar
#
# En tu config actual, polybar usa el módulo internal/pulseaudio, que se actualiza
# automáticamente; no hace falta reiniciar ni hacer hooks aquí.
exit 0
