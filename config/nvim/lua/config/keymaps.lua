-- keymaps.lua

-- Keymaps "globales" no atados a plugins concretos
local map = vim.keymap.set
local opt = { silent = true, noremap = true }

-- Navegación de ventanas/paneles (Neovim <-> tmux)
-- map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Focus left (nvim/tmux)" })
-- map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Focus down (nvim/tmux)" })
-- map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Focus up (nvim/tmux)" })
-- map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Focus right (nvim/tmux)" })
map("n", "<M-h>", "<C-w>h", { desc = "Go to left window (Alt)" })
map("n", "<M-l>", "<C-w>l", { desc = "Go to right window (Alt)" })

-- Selección/duplicado/mover líneas (tipo VSCode)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })
map("n", "<S-A-j>", "yyp", { desc = "Duplicate line down" })
map("n", "<S-A-k>", "yyP", { desc = "Duplicate line up" })
map("v", "<S-A-j>", "y'>pgv", { desc = "Duplicate selection down" })
map("v", "<S-A-k>", "y'<Pgv", { desc = "Duplicate selection up" })

-- Splits coherentes con i3/tmux
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Close window" })
map("n", '<leader>"', "<cmd>split<cr>", { desc = 'Split (")' })
map("n", "<leader>%", "<cmd>vsplit<cr>", { desc = "VSplit (%)" })

-- Cerrar otras ventanas (análogo a kill-pane -a)
map("n", "<leader><BS>", "<cmd>only<cr>", { desc = "Close other windows (only)" })

-- Selector de buffers (análogo a choose-tree)
map("n", "<leader>s", "<cmd>ls<CR>:b ", { desc = "Switch buffer" })

-- Resize tipo tmux (Alt+Shift+Flechas) — se mantiene Ctrl+Flechas también
map("n", "<A-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width (A-S-Left)" })
map("n", "<A-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width (A-S-Right)" })
map("n", "<A-S-Up>", "<cmd>resize +1<cr>", { desc = "Increase height (A-S-Up)" })
map("n", "<A-S-Down>", "<cmd>resize -1<cr>", { desc = "Decrease height (A-S-Down)" })

-- Resize  (Ctrl+Flechas) — se mantiene Ctrl+Flechas también
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width (C-Left)" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width (C-Right)" })
map("n", "<C-Up>", "<cmd>resize +1<cr>", { desc = "Increase height (C-Up)" })
map("n", "<C-Down>", "<cmd>resize -1<cr>", { desc = "Decrease height (C-Down)" })

-- Guardado alternativo (dentro de tmux, <C-s> es prefijo)
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write file" })

-- Búsqueda: evita choque con nvim-cmp (usa <C-f> en insert.)
map("n", "<C-f>", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("/", true, false, true), "n", false)
end, { desc = "Search prompt (/)" })
map("n", "<leader>/", "/", { desc = "Buscar (/)" })

-- Navegación de buffers (rápido, sin plugins)
map("n", "H", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Conserva el comportamiento nativo de H/L (top/bottom of screen) en gH/gL
map("n", "gH", "<cmd>normal! H<cr>", { desc = "Screen top" })
map("n", "gL", "<cmd>normal! L<cr>", { desc = "Screen bottom" })

-- Limpiar hightlight de búsqueda
map("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear search hightlight" })

-- Toggles de edición para el día a día
map("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle wrap" })
map("n", "<leader>tn", function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relativenumber" })
map("n", "<leader>ts", "<cmd>setlocal spell! spelllang=es,en<cr>", { desc = "Toggle spell (es/en)" })
