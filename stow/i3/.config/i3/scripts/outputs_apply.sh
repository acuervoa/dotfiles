#!/usr/bin/env bash
set -euo pipefail

# outputs_apply.sh
#
# Política:
#   - Workspaces impares (1,3,5,7,9) -> pantalla interna (eDP*/LVDS* o primary)
#   - Workspaces pares   (2,4,6,8,10) -> pantalla externa (primer output conectado distinto)
#   - Si no hay externa, todo va a la interna.
#
# Implementación sin crear workspaces:
#   - Genera un include para i3: ~/.config/i3/workspaces.local.conf
#   - Si cambia el contenido, escribe y hace `i3-msg reload`.

WORKSPACES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/i3/workspaces.local.conf"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '[outputs_apply] Falta comando requerido: %s\n' "$1" >&2
    exit 0
  }
}

need_cmd xrandr
need_cmd i3-msg

mkdir -p "$(dirname "$WORKSPACES_FILE")"

mapfile -t connected < <(xrandr --query | awk '/ connected/{print $1}')

if ((${#connected[@]} == 0)); then
  # Sin outputs detectados; no tocar el fichero.
  exit 0
fi

internal=""
external=""

# 1) Preferir panel interno
for o in "${connected[@]}"; do
  case "$o" in
    eDP*|LVDS*) internal="$o"; break ;;
  esac
done

# 2) Fallback a primary
if [[ -z "$internal" ]]; then
  internal="$(xrandr --query | awk '/ connected primary/{print $1; exit}' || true)"
fi

# 3) Último fallback: primero conectado
if [[ -z "$internal" ]]; then
  internal="${connected[0]}"
fi

for o in "${connected[@]}"; do
  if [[ "$o" != "$internal" ]]; then
    external="$o"
    break
  fi
done

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  printf '# Auto-generado por outputs_apply.sh (%s)\n' "$(date -Is 2>/dev/null || date)"
  printf '# internal=%s external=%s\n\n' "$internal" "${external:-}"

  for ws in 1 3 5 7 9; do
    printf 'workspace %s output %s\n' "$ws" "$internal"
  done

  out_even="${external:-$internal}"
  for ws in 2 4 6 8 10; do
    printf 'workspace %s output %s\n' "$ws" "$out_even"
  done
} >"$tmp"

# Si no existe aún, crearlo (debe existir antes de que i3 procese el include).
if [[ ! -f "$WORKSPACES_FILE" ]]; then
  install -m 0644 /dev/null "$WORKSPACES_FILE"
fi

if ! cmp -s "$tmp" "$WORKSPACES_FILE"; then
  install -m 0644 "$tmp" "$WORKSPACES_FILE"
  # reload aplica la nueva asignación a futuros workspaces sin crear ninguno.
  i3-msg reload >/dev/null 2>&1 || true
fi
