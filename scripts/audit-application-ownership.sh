#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Schema: CAPABILITY|capacidad|owner canónico
# Estas líneas son la fuente machine-readable del contrato de ownership.
# CAPABILITY|launcher|Rofi
# CAPABILITY|history|Atuin
# CAPABILITY|clipboard-history|clipmenu
# CAPABILITY|prompt|Starship
# CAPABILITY|panes|tmux
# CAPABILITY|windows|i3
# CAPABILITY|editor|Neovim
# CAPABILITY|git-visual|LazyGit
# CAPABILITY|notifications|Dunst

printf '%s\n' '# Application ownership audit'
printf '%s\n' '# APP|binary/path|versioned config|owner/context'

declare -a apps=(
  'Kitty|kitty|stow/kitty/.config/kitty/kitty.conf|terminal transport'
  'Rofi|rofi|stow/rofi/.config/rofi/config.rasi|visual selector'
  'Albert|albert|stow/albert/.config/albert/config|secondary launcher under review'
  'Dunst|dunst|stow/dunst/.config/dunst/dunstrc|notifications'
  'Polybar|polybar|stow/polybar/.config/polybar/config.ini|persistent status'
  'CopyQ|copyq|stow/copyq/.config/copyq/copyq.conf|clipboard history'
  'clipmenu|clipmenu|stow/i3/.config/i3/config|clipboard history selector'
  'ble.sh|/usr/share/blesh/ble.sh|stow/blesh/.config/blesh/blerc|line editing'
  'Atuin|atuin|stow/atuin/.config/atuin/config.toml|history backend'
  'FZF|fzf|stow/bash/.bashrc|text selection'
  'Starship|starship|stow/bash/.bashrc|prompt'
  'zoxide|zoxide|stow/bash/.bashrc|directory navigation'
  'direnv|direnv|stow/bash/.bashrc|project environment'
  'mise|mise|stow/mise/.config/mise/config.toml|runtime/tool versions'
  'fnm|fnm|stow/bash/.bashrc|Node runtime'
  'LazyGit|lazygit|stow/lazygit/.config/lazygit/config.yml|Git visual'
  'Yazi|yazi|stow/yazi/.config/yazi/yazi.toml|filesystem navigation'
  'lnav|lnav|stow/lnav|log analysis'
  'btop|btop|stow/btop/.config/btop/btop.conf|system monitoring'
  'Neovim|nvim|stow/nvim/.config/nvim/init.lua|editor and code workflows'
  'cava|cava|stow/cava/.config/cava/config|audio visualizer'
  'delta|delta|stow/git/.gitconfig|git diff pager'
  'gh-dash|gh|stow/gh-dash/.config/gh-dash/config.yml|GitHub PR/issue TUI dashboard'
  'gitleaks|gitleaks|scripts/check-secrets.sh|secret scanning (entropy + rules)'
  'difftastic|difft|stow/bash/.bash_aliases|structural diff, alias gdt'
  'ripgrep-all|rga|stow/bash/.bash_lib/nav.sh|content search in PDFs/docs, function rgaf'
)

for entry in "${apps[@]}"; do
  IFS='|' read -r name binary config context <<<"$entry"
  if [[ "$binary" = /* ]]; then
    available=$([ -e "$binary" ] && printf 'available' || printf 'missing')
  else
    available=$(command -v "$binary" >/dev/null 2>&1 && printf 'available' || printf 'missing')
  fi
  config_path="$repo_root/$config"
  config_state=$([ -e "$config_path" ] && printf 'tracked' || printf 'missing')
  printf 'APP|%s|%s|%s|%s|%s|%s\n' "$name" "$binary" "$config" "$config_state" "$available" "$context"
done

printf '%s\n' '# CAPABILITY|capability|canonical owner'
grep '^# CAPABILITY|' "${BASH_SOURCE[0]}" | sed 's/^# //'
