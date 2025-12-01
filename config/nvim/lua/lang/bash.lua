-- lua/lang/bash.lua
-- Configuración especifica para Bash / shell scripts:
-- LSP (futuro), formateo y lint

local M = {}

-- Filetype principal que usa Neovim para scripts bash
-- (por defecto es "sh" aunque el shebang sea /usr/bin/env bash)
M.ft = "sh"

-- LSP (placeholder para integrar más adelante desde plugins/lsp.lua)
M.lsp = {
  server = "bashls",
  settings = {
    -- Por ahora la configuración por defecto del servidor
    -- filetypes = {"sh"}
    -- diagnostics = { ...},
  },
}

-- Formateo (conform.nvim)
-- Requiere tener 'shfmt' en el PATH (pacman: shfmt, etc.)
M.format = {
  formatters = { "shfmt" },
}

-- Lint (nvim-lint)
-- Requiere tener 'shellcheck' en el PATH
M.lint = {
  linters = { "shellcheck" },
}

-- No test especificos
M.tests = {}

return M
