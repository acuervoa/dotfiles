#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_home="$(mktemp -d)"
trap 'rm -rf -- "$fixture_home"' EXIT

export HOME="$fixture_home"
export DOTFILES="$repo_root"
export DRY_RUN=false

source "$repo_root/scripts/lib/common.sh"

mkdir -p "$HOME/.config/autostart"
printf '%s\n' '[Desktop Entry]' > "$HOME/.config/autostart/Nextcloud.desktop"

ensure_pers_gui_negative_state

test ! -e "$HOME/.config/autostart/Nextcloud.desktop"
ensure_pers_gui_negative_state
test ! -e "$HOME/.config/autostart/Nextcloud.desktop"

printf '%s\n' '[OK] PERS-GUI negative policy is idempotent'
