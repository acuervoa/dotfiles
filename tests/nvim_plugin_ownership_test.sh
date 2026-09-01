#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plugin_dir="$repo_root/stow/nvim/.config/nvim/lua/plugins"

if rg -n 'numToStr/Comment\.nvim' "$plugin_dir/comment.lua" >/dev/null; then
  printf 'FAIL: comment.lua conserva un owner activo\n' >&2
  exit 1
fi
if rg -n '^[[:space:]]*"JoosepAlviste/nvim-ts-context-commentstring"' "$plugin_dir/treesitter.lua" >/dev/null; then
  printf 'FAIL: treesitter.lua conserva un owner activo\n' >&2
  exit 1
fi
rg -n 'numToStr/Comment\.nvim' "$plugin_dir/editing.lua" >/dev/null
rg -n 'JoosepAlviste/nvim-ts-context-commentstring' "$plugin_dir/editing.lua" >/dev/null

printf 'PASS: ownership único de plugins críticos\n'
