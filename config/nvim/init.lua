-- init.lua — Neovim "VSCode-like" (NVIM 0.11+)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
