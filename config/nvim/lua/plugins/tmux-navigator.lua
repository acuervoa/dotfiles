-- tmux-navigator (Neovim, lazy.nvim)
return {
	"christoomey/vim-tmux-navigator",
	-- Carga inmediata para que funcione desde el arranque
	lazy = false,
	init = function()
		-- Usaremos nuestros propios mappings
		vim.g.tmux_navigator_no_mappings = 1
		-- No salir del zoom de tmux al moverse desde nvim
		vim.g.tmux_navigator_disable_when_zoomed = 1
	end,
	config = function()
		local map = vim.keymap.set
		local opts = { silent = true, desc = "TmuxNavigate" }
		map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
		map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", opts)
		map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", opts)
		map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", opts)
		-- Opcional: pane previo con <C-\>
		map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", opts)
	end,
}
