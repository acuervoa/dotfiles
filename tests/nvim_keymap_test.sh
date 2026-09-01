#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/stow/nvim/.config/nvim/init.lua"

test -f "$config"
nvim --headless -u "$config" \
  '+lua local function mapped(mode, lhs) local item = vim.fn.maparg(lhs, mode, false, true); assert(item.lhs ~= "", "mapping ausente: " .. mode .. " " .. lhs) end; local ok, err = pcall(function() for _, lhs in ipairs({"<leader>w", "<leader>q", "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<leader>ff", "<leader>fg", "<leader>cf", "<leader>tt", "<leader>db", "<leader>ce", "<leader>cz", "<leader>cF", "<leader>cr", "<leader>cD"}) do mapped("n", lhs) end; for _, name in ipairs({"CodexExplain", "CodexExplainRepo", "CodexFix", "CodexRefactor", "CodexDiff", "CodexVisual"}) do assert(vim.fn.exists(":" .. name) == 2, "comando ausente: " .. name) end end); if not ok then print(err); vim.cmd("cquit 1") end' \
  '+qa'

printf 'PASS: mappings y comandos Neovim estables\n'
