#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git_lib="$repo_root/stow/bash/.bash_lib/git.sh"
nav_lib="$repo_root/stow/bash/.bash_lib/nav.sh"
misc_lib="$repo_root/stow/bash/.bash_lib/misc.sh"
docker_lib="$repo_root/stow/bash/.bash_lib/docker.sh"
tmux_config="$repo_root/stow/tmux/.tmux.conf"
nvim_root="$repo_root/stow/nvim/.config/nvim"

for file in "$git_lib" "$nav_lib" "$misc_lib" "$docker_lib" "$tmux_config"; do
  test -f "$file"
done

# Entradas Bash del workflow: proyecto, edición, filesystem, Git y logs.
grep -Fq 'tproj()' "$nav_lib"
grep -Fq 'dev()' "$misc_lib"
grep -Fq 'y()' "$misc_lib"
grep -Fq 'dlogs()' "$docker_lib"
grep -Fq 'lg()' "$git_lib"
grep -Fq 'command lazygit' "$git_lib"

# Git visual tiene tres entradas equivalentes y el mismo contexto de proyecto.
grep -Fq 'bind g display-popup' "$tmux_config"
grep -Fq 'lazygit' "$tmux_config"
grep -Fq '"<leader>gg"' "$nvim_root/lua/plugins/git.lua"

# Neovim conserva filesystem/editor separados de Bash/Yazi y ofrece tareas de
# proyecto sin ejecutar nada durante este contrato estático.
grep -Fq '"<leader>pt"' "$nvim_root/lua/plugins/tests.lua"
grep -Fq '"<leader>pT"' "$nvim_root/lua/plugins/tests.lua"
grep -Fq '"<leader>pf"' "$nvim_root/lua/plugins/format_lint.lua"
grep -Fq '"<leader>pl"' "$nvim_root/lua/plugins/format_lint.lua"
grep -Fq '"<leader>po"' "$nvim_root/lua/plugins/tasks.lua"

printf '%s\n' 'PASS: workflow de proyecto, Git, logs y filesystem cubierto'
