--- autocmds.lua

--- Highlight al copiar
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

-- Auto-cerrar neo-tree si es la última ventana
vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local tree_wins, floating_wins = {}, {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("neo%-tree") ~= nil then
				table.insert(tree_wins, w)
			end
			if vim.api.nvim_win_get_config(w).relative ~= "" then
				table.insert(floating_wins, w)
			end
		end
		if #wins - #floating_wins - #tree_wins == 1 then
			for _, w in ipairs(tree_wins) do
				pcall(vim.api.nvim_win_close, w, true)
			end
		end
	end,
})

-- Restaurar posición del cursor
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Auto-balance al redimensionar
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Cerrar paneles/ventanas auxiliares con 'q'
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("q_to_close", { clear = true }),
	pattern = {
		"help",
		"man",
		"lspinfo",
		"qf",
		"checkhealth",
		"OverseerList",
		"neotest-summary",
		"neo-tree",
		"Outline",
		"dap-float",
	},
	callback = function(ev)
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
	end,
})

-- Big file mode: desactivar cosas caras en archivos grandes
do
	local bigfile_group = vim.api.nvim_create_augroup("bigfile_mode", { clear = true })

	vim.api.nvim_create_autocmd("BufReadPre", {
		group = bigfile_group,
		callback = function(ev)
			local ok, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
			if not ok or not stat then
				return
			end

			-- Umbral ajustable: 2MB
			local BIGFILE_THRESHOLD = vim.g.bigfile_treshhold or (2 * 1024 * 1024)
			if stat.size > BIGFILE_THRESHOLD then
				vim.b.bigfile = true

				-- Treesitter: desactivar highlight/indent
				pcall(vim.cmd, "TSBufDisable highlight")
				pcall(vim.cmd, "TSBufDisable indent")

				-- Opciones locales mas ligeras
				vim.opt_local.foldmethod = "manual"
				vim.opt_local.swapfile = false
				vim.opt_local.undofile = false
				vim.opt_local.wrap = false
			end
		end,
	})
end
