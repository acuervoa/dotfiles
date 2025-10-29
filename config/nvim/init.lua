-- init.lua — Neovim "VSCode-like" (NVIM 0.11+)

-- move backup, swap and undo files to .cache
local cache = os.getenv("HOME") .. "/.cache/nvim"

vim.opt.backup = true
vim.opt.backupext = ".bak"
vim.opt.backupdir = { cache .. "/backup//" }

vim.opt.swapfile = true
vim.opt.directory = { cache .. "/swap//" }

vim.opt.undofile = true
vim.opt.undodir = { cache .. "/undo//" }

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Acelera arranque cacheando rquire()
if vim.loader then
	vim.loader.enable()
end

-- load configs
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
