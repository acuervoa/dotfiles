#!/usr/bin/env bash
# Toggle/crear Obsidian como scratchpad, sin duplicados

MARK="scratch_obs"
CLASS="obsidian"

# ¿Hay ya una ventana de Obsidian marcada como scractchpad?
NODE=$(
  i3-msg -t get_tree | jq -r '
    .. | objects
    | select(.window_properties?.class=="'"$CLASS"'")
    | select(.marks // [] | index("'"$MARK"'"))
    | "\(.id) \(.visible)"
  ' | head -n1
)

if [ -n "$NODE" ]; then
  ID=${NODE%% *}
  VISIBLE=${NODE#* }

  if [ "$VISIBLE" = "true" ]; then
    # Esta visible -> ocultar (mandarla al scratchpad)
    i3-msg "[con_id=\"$ID\"] move to scratchpad" >/dev/null
  else
    # Está oculta o en otro workspace -> mostrar
    i3-msg "[con_id=\"$ID\"] scratchpad show" >/dev/null
  fi
  exit 0
fi

# No hay marca. ¿Hay alguna ventana Obsidian viva?
OBS_ID=$(
  i3-msg -t get_tree | jq -r '
    .. | objects
    | select(.window_properties?.class=="'"$CLASS"'")
    | .id
  ' | head -n1
)

if [ -n "$OBS_ID" ]; then
  # Hay obsidian pero sin preparar. La marcamos y la mandamos al scratchpad
  i3-msg "[con_id=\"$OBS_ID\"] mark --replace $MARK, \
    floating enable, move position center, \
    resize set 1600 900, move to scratchpad, scratchpad show" >/dev/null
  exit 0
fi

# No hay ninguna ventana Obsidian Lanzamos y enganchamos la primera que aparezca
obsidian &

for _ in 1 2 3 4 5 6 7 8 9 10; do
  sleep 0.2
  OBS_ID=$(
    i3-msg -t get_tree | jq -r '
        .. | objects
        | select(.window_properties?.class=="'"$CLASS"'")
        | .id
      ' | head -n1
  )

  if [ -n "$OBS_ID" ]; then
    i3-msg "[con_id=\"$OBS_ID\"] mark --replace $MARK, \
        floating enable, move position center, \
        resize set 1600 900, move to scratchpad, scratchpad show" >/dev/null
    exit 0
  fi
done

# Fallback
i3-msg '[class="obsidian"] floating enable, move position center, resize set 1600 900, move to scratchpad, scratchpad show' >/dev/null
