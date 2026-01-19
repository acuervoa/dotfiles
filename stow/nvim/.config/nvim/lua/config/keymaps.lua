-- keymaps.lua

-- Keymaps "globales" no atados a plugins concretos
local map = vim.keymap.set

-- Borrar buffert actual sin cerrar Neovim
local function smart_bdelete(force)
	local cmd = force and "bd!" or "bd"
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	local cur = vim.api.nvim_get_current_buf()

	-- Sin no hay buffers listados, no hacemos nada raro
	if #bufs == 0 then
		return
	end

	-- Caso especial: solo hay un buffer listado -> crea uno nuevoy borra el anterior
	if #bufs == 1 then
		vim.cmd("enew") -- nuevo buffer vacio, pasa a ser el actual
		vim.cmd(string.format("%s %d", cmd, cur))
		return
	end

	-- Caso normal: Hay mas de un buffer -> bdelete el actual
	vim.cmd(cmd)
end

-- Navegación de ventanas/paneles (Neovim <-> tmux)
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

-- Selector de buffers (análogo a choose-tree)
map("n", "<leader>bb", "<cmd>ls<CR>:b ", { desc = "Switch buffer" })

-- Navegación de buffers (rápido, sin plugins)
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Cierre de buffers (sin cerrar Neovim)
map("n", "<leader>bd", function()
	smart_bdelete(false)
end, { desc = "Delete current buffer" })

map("n", "<leader>bD", function()
	smart_bdelete(true)
end, { desc = "Force delete current buffer" })

-- Cerrar todos los buffers excepto el actual
map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted and bufnr ~= current then
			vim.cmd("bd " .. bufnr)
		end
	end
end, { desc = "Delete other buffers" })

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
map("n", "<leader>ts", function()
	local es_spell = vim.fn.stdpath("config") .. "/spell/es.utf-8.spl"
	if vim.fn.filereadable(es_spell) == 1 then
		vim.cmd("setlocal spell! spelllang=es,en")
	else
		vim.cmd("setlocal spell! spelllang=en")
	end
end, { desc = "Toggle spell (es/en)" })
