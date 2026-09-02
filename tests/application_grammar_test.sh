#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shortcuts="$repo_root/SHORTCUTS.md"
nvim_shortcuts="$repo_root/stow/nvim/.config/nvim/SHORTCUTS.md"
nvim_usage="$repo_root/stow/nvim/.config/nvim/USAGE.md"

bash "$repo_root/scripts/generate_shortcuts_doc.sh" >/dev/null
test -f "$shortcuts"

# La documentación generada debe exponer scopes y owners, no sólo una lista
# de teclas aisladas.
grep -Fq '## Gramática coordinada y owners' "$shortcuts"
grep -Fq 'i3' "$shortcuts"
grep -Fq 'tmux' "$shortcuts"
grep -Fq 'Bash/ble.sh' "$shortcuts"
grep -Fq 'Neovim' "$shortcuts"
grep -Fq 'Rofi' "$shortcuts"
grep -Fq 'clipmenu' "$shortcuts"

# Las docs del editor explican la semántica contextual de las teclas cortas.
grep -Fq 'p/r/y/n/z' "$nvim_shortcuts"
grep -Fq 'Bash' "$nvim_shortcuts"
grep -Fq 'Vim' "$nvim_shortcuts"
grep -Fq 'p/r/y/n/z' "$nvim_usage"
grep -Fq '<leader>gg' "$nvim_usage"
grep -Fq 'C-s g' "$nvim_usage"
grep -Fq 'lg' "$nvim_usage"

printf '%s\n' 'PASS: gramática coordinada y documentación contextual presentes'
