#!/usr/bin/env bash
set -euo pipefail
# Toggle/crear una kitty en scratchpad con WM_CLASS = scratch-terminal

poll_seconds="${I3_SCRATCH_POLL_SECONDS:-0.15}"
[[ "$poll_seconds" =~ ^[0-9]+([.][0-9]+)?$ ]] || poll_seconds=0.15

# ¿Existe ya alguna ventana con esa clase/instancia?
HAS=$(i3-msg -t get_tree | jq -r '
  .. | objects
  | select(.window_properties? and
           (.window_properties.class=="scratch-terminal" or
            .window_properties.instance=="scratch-terminal"))
  | .id
' | head -n1)

if [ -n "$HAS" ]; then
  # Ya existe: toggle mostrar/ocultar esa/esas (si hay varias, actuará sobre las que coincidan)
  i3-msg '[class="scratch-terminal" instance="scratch-terminal"] scratchpad show' >/dev/null
  exit 0
fi

# No existe: crear una nueva
kitty --class scratch-terminal &

# Esperar a que aparezca y asegurar: mark + mover a scratchpad + mostrar
for _ in 1 2 3 4 5; do
  sleep "$poll_seconds"
  i3-msg '[class="scratch-terminal" instance="scratch-terminal"] mark --replace scratch_term, move to scratchpad' >/dev/null
  # ¿ya está marcada?
  if i3-msg -t get_marks | jq -e 'index("scratch_term") != null' >/dev/null; then
    i3-msg '[con_mark="scratch_term"] scratchpad show' >/dev/null
    exit 0
  fi
done

# Fallback final por si la marca falló por timing
i3-msg '[class="scratch-terminal" instance="scratch-terminal"] move to scratchpad, scratchpad show' >/dev/null
