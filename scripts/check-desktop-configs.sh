#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/check-desktop-configs.sh [opciones]

Valida de forma reproducible las configuraciones versionadas de PERS-GUI.

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

check_pers_gui_packages() {
  local manifest="$REPO_ROOT/manifests/pers-gui-packages.txt"
  local -a packages missing duplicates
  local package

  check_file "$manifest"
  [ -f "$manifest" ] || return

  mapfile -t packages < <(sed -E 's/[[:space:]]+#.*$//' "$manifest" | awk '!/^[[:space:]]*#/ && NF { print $1 }')
  mapfile -t duplicates < <(printf '%s\n' "${packages[@]}" | sort | uniq -d)
  if ((${#duplicates[@]})); then
    printf '[ERROR] Paquetes PERS-GUI duplicados: %s\n' "${duplicates[*]}" >&2
    failures=$((failures + 1))
  fi

  if [ "$STATIC_ONLY" = true ]; then
    printf '[INFO] --static: se omite la comprobación de paquetes instalados (estado del host)\n'
    return
  fi

  if ! command -v pacman >/dev/null 2>&1; then
    printf '[ERROR] pacman no está disponible para comprobar PERS-GUI\n' >&2
    failures=$((failures + 1))
    printf 'PERS_GUI_PACKAGES_PRESENT=FAIL\n'
    printf 'MISSING_PACKAGES=<pacman-unavailable>\n'
    return
  fi

  missing=()
  for package in "${packages[@]}"; do
    pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
  done

  if ((${#missing[@]})); then
    printf '[ERROR] Faltan paquetes PERS-GUI: %s\n' "${missing[*]}" >&2
    failures=$((failures + 1))
    printf 'PERS_GUI_PACKAGES_PRESENT=FAIL\n'
    printf 'MISSING_PACKAGES=%s\n' "${missing[*]}"
  else
    printf 'PERS_GUI_PACKAGES_PRESENT=PASS\n'
  fi
}

check_pers_gui_packages

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

check_repo_path() {
  local file="$1" target="$2"
  check_file "$file"
  if [ -f "$file" ] && [ -L "$target" ] && [ "$(readlink -f "$target")" != "$(readlink -f "$file")" ]; then
    printf '[ERROR] Symlink PERS-GUI no apunta al repo: %s\n' "$target" >&2
    failures=$((failures + 1))
  fi
}

check_mime_default() {
  local mime="$1" expected="$2" actual
  if ! command -v xdg-mime >/dev/null 2>&1; then
    printf '[ERROR] xdg-mime no está instalado\n' >&2
    failures=$((failures + 1))
    return
  fi
  actual="$(xdg-mime query default "$mime" 2>/dev/null || true)"
  if [ "$actual" != "$expected" ]; then
    printf '[ERROR] MIME %s: esperado=%s actual=%s\n' "$mime" "$expected" "${actual:-<vacío>}" >&2
    failures=$((failures + 1))
  fi
}

gui_scripts=(
  "$REPO_ROOT/stow/i3/.config/i3/scripts/i3lock.sh"
  "$REPO_ROOT/stow/i3/.config/i3/scripts/i3exit.sh"
  "$REPO_ROOT/stow/i3/.config/i3/scripts/session-start.sh"
  "$REPO_ROOT/stow/i3/.config/i3/scripts/session-exit.sh"
  "$REPO_ROOT/stow/i3/.config/i3/scripts/screenshot_maim.sh"
  "$REPO_ROOT/stow/i3/.config/i3/scripts/mode_system.sh"
)
for script in "${gui_scripts[@]}"; do
  check_file "$script"
  if [ -f "$script" ]; then
    bash -n "$script" || failures=$((failures + 1))
  fi
done

check_repo_path \
  "$REPO_ROOT/stow/systemd/.config/systemd/user/i3-session.target" \
  "$HOME/.config/systemd/user/i3-session.target"
check_repo_path \
  "$REPO_ROOT/stow/systemd/.config/systemd/user/clipmenud.service.d/override.conf" \
  "$HOME/.config/systemd/user/clipmenud.service.d/override.conf"
check_repo_path \
  "$REPO_ROOT/stow/Nextcloud/.local/share/dbus-1/services/com.nextcloudgmbh.Nextcloud.service" \
  "$HOME/.local/share/dbus-1/services/com.nextcloudgmbh.Nextcloud.service"
check_repo_path \
  "$REPO_ROOT/stow/dotfiles/.config/mimeapps.list" \
  "$HOME/.config/mimeapps.list"

nextcloud_service="$REPO_ROOT/stow/Nextcloud/.local/share/dbus-1/services/com.nextcloudgmbh.Nextcloud.service"
if [ -f "$nextcloud_service" ]; then
  rg -q '^Name=com\.nextcloudgmbh\.Nextcloud$' "$nextcloud_service" || failures=$((failures + 1))
  rg -q '^Exec=/usr/bin/false$' "$nextcloud_service" || failures=$((failures + 1))
fi
if [ -e "$HOME/.config/autostart/Nextcloud.desktop" ] || [ -L "$HOME/.config/autostart/Nextcloud.desktop" ]; then
  printf '[ERROR] Nextcloud.desktop debe estar ausente: %s\n' "$HOME/.config/autostart/Nextcloud.desktop" >&2
  failures=$((failures + 1))
fi

# Los defaults MIME son estado del host: solo se comprueban fuera de --static.
for mime_pair in \
  'inode/directory thunar.desktop' \
  'text/plain nvim-kitty.desktop' \
  'application/pdf org.pwmt.zathura.desktop' \
  'image/png feh.desktop' \
  'video/mp4 mpv.desktop' \
  'audio/mpeg mpv.desktop' \
  'application/zip xarchiver.desktop' \
  'text/html firefox.desktop' \
  'x-scheme-handler/http firefox.desktop' \
  'x-scheme-handler/https firefox.desktop' \
  'x-scheme-handler/mailto firefox.desktop'; do
  [ "$STATIC_ONLY" = true ] && continue
  read -r mime expected <<<"$mime_pair"
  check_mime_default "$mime" "$expected"
done

if [ "$STATIC_ONLY" != true ] && command -v systemd-analyze >/dev/null 2>&1; then
  systemd-analyze --user verify "$HOME/.config/systemd/user/i3-session.target" >/dev/null 2>&1 || {
    printf '[ERROR] systemd-analyze --user verify falló para i3-session.target\n' >&2
    failures=$((failures + 1))
  }
fi

i3exit="$REPO_ROOT/stow/i3/.config/i3/scripts/i3exit.sh"
if [ -f "$i3exit" ]; then
  rg -q 'exec ~/.config/i3/scripts/session-exit\.sh' "$i3exit" || failures=$((failures + 1))
  rg -q 'i3lock\.sh.*&& systemctl suspend' "$i3exit" || failures=$((failures + 1))
  rg -q 'systemctl reboot' "$i3exit" || failures=$((failures + 1))
  rg -q 'systemctl poweroff' "$i3exit" || failures=$((failures + 1))
  if rg -q 'hibernate|systemctl hibernate' "$i3exit"; then
    printf '[ERROR] hibernate no debe reaparecer en i3exit.sh\n' >&2
    failures=$((failures + 1))
  fi
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
