#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/stow/nvim/.config/nvim/init.lua"

nvim --headless -u "$config" \
  '+Lazy! load conform.nvim' \
  '+Lazy! load nvim-lint' \
  '+lua local function mapped(lhs) local item = vim.fn.maparg(lhs, "n", false, true); assert(item.lhs and item.lhs ~= "", "mapping ausente: " .. lhs) end; local ok, err = pcall(function() for _, lhs in ipairs({"<leader>ff", "<leader>fg", "<leader>fb", "<leader>xx", "<leader>cf", "<leader>tt", "<leader>db", "<leader>gg", "<leader>ot", "<leader>or", "<leader>e", "<leader>sr", "<leader>pt", "<leader>pT", "<leader>pl", "<leader>pf", "<leader>po"}) do mapped(lhs) end; for _, name in ipairs({"FormatToggle", "FormatToggleBuffer", "Lint", "CodexExplain", "CodexExplainRepo", "CodexFix", "CodexRefactor", "CodexDiff"}) do assert(vim.fn.exists(":" .. name) == 2, "comando ausente: " .. name) end; assert(type(require("lang.php").tests) == "table", "perfil PHP ausente") end); if not ok then print(err); os.exit(1) end' \
  '+qa'

printf 'PASS: workflows general/backend disponibles\n'
