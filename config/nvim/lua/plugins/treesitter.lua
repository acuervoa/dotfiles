-- nvim-treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"php",
				"phpdoc",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"yaml",
				"html",
				"css",
				"scss",
				"bash",
				"markdown",
				"markdown_inline",
			},
			auto_install = true,
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader><CR>",
					node_incremental = "<leader><CR>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
