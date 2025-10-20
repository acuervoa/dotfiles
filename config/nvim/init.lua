-- init.lua — Neovim "VSCode-like" (NVIM 0.11+)

-- Acelera arranque cacheando rquire()
if vim.loader then
	vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
