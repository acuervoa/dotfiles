-- Tree-sitter for Neovim >= 0.12
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})

			ts.install({
				"lua",
				"vim",
				"vimdoc",
				"query",
				"bash",
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
				"markdown",
				"markdown_inline",
				"python",
				"go",
				"gomod",
				"gosum",
				"rust",
				"dockerfile",
				"toml",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)

					vim.bo[args.buf].indentexpr =
						"v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,

		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end)
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		lazy = false,
		opts = {},
	},

	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = false,
	},
}
