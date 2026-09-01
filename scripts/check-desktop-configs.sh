#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/check-desktop-configs.sh [opciones]

Valida de forma reproducible las configuraciones versionadas de i3 y tmux.

Opciones:
  --static       Solo comprueba archivos, includes y scripts referenciados
  --strict       Falla si no están disponibles i3 o tmux para validar runtime
  -h, --help     Muestra esta ayuda
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATIC_ONLY=false
STRICT=false

while (($# > 0)); do
  case "$1" in
  --static) STATIC_ONLY=true ;;
  --strict) STRICT=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
    usage >&2
    exit 2
    ;;
  esac
  shift
done

failures=0
check_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    printf '[ERROR] Falta archivo: %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
}

check_script_target() {
  local target="$1" relative candidate
  case "$target" in
  '$HOME/.config/'*)
    relative="${target#\$HOME/.config/}"
    candidate="$(find "$REPO_ROOT/stow" -path "*/.config/${relative}" -type f -print -quit 2>/dev/null || true)"
    ;;
  \~/.config/*)
    relative="${target#\~/.config/}"
    candidate="$(find "$REPO_ROOT/stow" -path "*/.config/${relative}" -type f -print -quit 2>/dev/null || true)"
    ;;
  '$HOME/'*)
    relative="${target#\$HOME/}"
    candidate="$(find "$REPO_ROOT/stow" -path "*/${relative}" -type f -print -quit 2>/dev/null || true)"
    ;;
  *) return 0 ;;
  esac
  if [ -z "$candidate" ]; then
    printf '[WARN] Target no resoluble en el repo: %s\n' "$target" >&2
  fi
}

i3_config="$REPO_ROOT/stow/i3/.config/i3/config"
tmux_config="$REPO_ROOT/stow/tmux/.tmux.conf"
check_file "$i3_config"
check_file "$tmux_config"

if [ -f "$i3_config" ]; then
  include_path="$REPO_ROOT/stow/i3/.config/i3/workspaces.local.conf"
  if ! rg -q '^include[[:space:]]+~/.config/i3/workspaces\.local\.conf' "$i3_config"; then
    printf '[ERROR] El include dinámico de workspaces no está declarado\n' >&2
    failures=$((failures + 1))
  fi
  if [ ! -f "$include_path" ]; then
    printf '[INFO] Include generado ausente en checkout: %s\n' "$include_path"
  fi

  while IFS= read -r target; do
    check_script_target "$target"
  done < <(rg -o '(\$HOME|~/.config)/[^[:space:]]+\.sh' "$i3_config" | sort -u)
fi

if [ "$STATIC_ONLY" = true ]; then
  printf '[INFO] Validación estática i3/tmux completada\n'
else
  if command -v i3 >/dev/null 2>&1; then
    i3 -C -c "$i3_config"
  elif [ "$STRICT" = true ]; then
    printf '[ERROR] i3 no está instalado\n' >&2
    failures=$((failures + 1))
  else
    printf '[WARN] i3 no está instalado; omitiendo parser\n' >&2
  fi

  if command -v tmux >/dev/null 2>&1; then
    socket_dir="$(mktemp -d)"
    socket="$socket_dir/server.sock"
    cleanup() {
      tmux -S "$socket" kill-server >/dev/null 2>&1 || true
      rm -rf -- "$socket_dir"
    }
    trap cleanup EXIT
    if ! timeout 8 tmux -S "$socket" -f "$tmux_config" new-session -d -s audit >/dev/null 2>&1; then
      printf '[ERROR] tmux no pudo cargar la configuración\n' >&2
      failures=$((failures + 1))
    else
      [ "$(tmux -S "$socket" show-options -gqv prefix)" = C-s ] || {
        printf '[ERROR] Prefix tmux inesperado\n' >&2
        failures=$((failures + 1))
      }
      tmux -S "$socket" list-keys -T prefix >/dev/null
    fi
  elif [ "$STRICT" = true ]; then
    printf '[ERROR] tmux no está instalado\n' >&2
    failures=$((failures + 1))
  else
    printf '[WARN] tmux no está instalado; omitiendo parser\n' >&2
  fi
fi

if [ "$failures" -gt 0 ]; then
  printf '[ERROR] %d comprobación(es) fallaron\n' "$failures" >&2
  exit 1
fi
printf '[OK] Configuraciones i3/tmux válidas\n'
