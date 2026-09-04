#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/stow/nvim/.config/nvim/init.lua"

nvim --headless --cmd "set rtp^=$repo_root/stow/nvim/.config/nvim" -u "$config" \
  '+lua local ok, err = pcall(function() local mod = require("config.lsp_log"); assert(type(mod.rotate_if_needed) == "function", "rotación LSP ausente"); assert(mod.max_bytes == 5 * 1024 * 1024, "límite de log inesperado"); local path = vim.fn.tempname(); vim.fn.writefile({ string.rep("x", mod.max_bytes + 1) }, path); assert(mod.rotate_if_needed(path), "el log grande no se rotó"); assert(vim.fn.filereadable(path) == 0, "el log original sigue presente"); assert(vim.fn.getfsize(path .. ".1") > mod.max_bytes, "backup de log incompleto"); vim.fn.delete(path .. ".1"); local pack_root = vim.fn.stdpath("data") .. "/site/pack"; assert(vim.fn.isdirectory(pack_root .. "/core/opt") == 1, "directorio base vim.pack ausente"); assert(#vim.fn.glob(pack_root .. "/core/opt/*", false, true) == 0, "plugins vim.pack core inesperados"); assert(vim.fn.isdirectory(pack_root .. "/dev") == 0, "residuo vim.pack dev presente") end); if not ok then print(err); vim.cmd("cquit 1") end' \
  '+qa'

printf '%s\n' "PASS: contrato de salud LSP y residuos vim.pack"
