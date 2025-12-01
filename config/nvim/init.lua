-- init.lua — Neovim "VSCode-like" (NVIM 0.11+)

-- move backup, swap and undo files to .cache
local cache = os.getenv("HOME") .. "/.cache/nvim"

local function ensure_dir(path)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, "p")
	end
end

ensure_dir(cache .. "/backup")
ensure_dir(cache .. "/swap")
ensure_dir(cache .. "/undo")

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

-- Acelera arranque cacheando require()
if vim.loader then
	vim.loader.enable()
end

-- load configs
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
