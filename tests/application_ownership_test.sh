#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit="$repo_root/scripts/audit-application-ownership.sh"

test -x "$audit"
bash -n "$audit"

ownership="$({ grep '^# CAPABILITY|' "$audit" || true; } | sed 's/^# //')"
test -n "$ownership"

while IFS='|' read -r record capability owner; do
  test "$record" = CAPABILITY
  test -n "$capability"
  test -n "$owner"
  count=$(printf '%s\n' "$ownership" | awk -F'|' -v wanted="$capability" '$1 == "CAPABILITY" && $2 == wanted { count++ } END { print count + 0 }')
  test "$count" -eq 1 || {
    printf 'ownership duplicado o ausente: %s (%s entradas)\n' "$capability" "$count" >&2
    exit 1
  }
done <<<"$ownership"

output="$($audit)"
for app in Kitty Rofi Dunst Polybar clipmenu 'ble.sh' Atuin FZF Starship zoxide direnv mise LazyGit Yazi lnav btop Neovim; do
  printf '%s\n' "$output" | grep -Fq "APP|$app|" || {
    printf 'aplicativo ausente del inventario: %s\n' "$app" >&2
    exit 1
  }
done

for retired in Albert CopyQ fnm ripgrep-all; do
  if printf '%s\n' "$output" | grep -Fq "APP|$retired|"; then
    printf 'herramienta retirada todavía activa en el inventario: %s\n' "$retired" >&2
    exit 1
  fi
done

printf '%s\n' 'PASS: ownership y baseline de aplicativos coherentes'
