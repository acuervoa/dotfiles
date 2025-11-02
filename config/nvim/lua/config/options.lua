-- Opciones básicas (estilo VSCode)
local o = vim.opt
o.number = true
o.relativenumber = true
o.hlsearch = true
o.inccommand = "split"
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.termguicolors = true
o.signcolumn = "yes"
o.updatetime = 250
o.timeoutlen = 300
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.wrap = false
o.undofile = true
-- FIX: winborder no es option global (evita error de inicio)

-- Desactiar providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
