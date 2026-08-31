#!/usr/bin/env bash
set -euo pipefail

# screenshot_maim.sh
#
# Uso:
#   screenshot_maim.sh select
#   screenshot_maim.sh full
#   screenshot_maim.sh save-select
#   screenshot_maim.sh delay <segundos> select|save-select
#
# Pausa picom solo mientras maim/slop está activo para evitar blur
# en el overlay de selección.

mode="${1:-}"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
picom_was_running=0

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Captura de pantalla" "$1"
  fi
}

restore_picom() {
  if [[ "$picom_was_running" -eq 1 ]]; then
    nohup picom -b >/dev/null 2>&1 &
  fi
}

run_capture() {
  if pgrep -x picom >/dev/null 2>&1; then
    picom_was_running=1
    pkill -x picom >/dev/null 2>&1 || true
    sleep 0.2
  fi

  trap restore_picom EXIT

  case "$mode" in
    select)
      maim -s | xclip -selection clipboard -t image/png
      notify "Captura copiada al portapapeles."
      ;;
    full)
      maim | xclip -selection clipboard -t image/png
      notify "Captura completa copiada al portapapeles."
      ;;
    save-select)
      mkdir -p "$HOME/Pictures/Screenshots"
      output="$HOME/Pictures/Screenshots/screenshot-$timestamp.png"
      maim -s "$output"
      xclip -selection clipboard -t image/png < "$output"
      notify "Captura guardada en $output"
      ;;
    *)
      printf 'Uso: %s {select|full|save-select}\n' "${0##*/}" >&2
      exit 2
      ;;
  esac
}

case "$mode" in
  delay)
    delay_seconds="${2:-0}"
    mode="${3:-}"
    if [[ "$delay_seconds" =~ ^[0-9]+$ ]] && [[ "$delay_seconds" -gt 0 ]]; then
      sleep "$delay_seconds"
      run_capture
    else
      printf 'Uso: %s delay <segundos> {select|save-select}\n' "${0##*/}" >&2
      exit 2
    fi
    ;;
  select|full|save-select)
    run_capture
    ;;
  *)
    printf 'Uso: %s {select|full|save-select|delay}\n' "${0##*/}" >&2
    exit 2
    ;;
esac
