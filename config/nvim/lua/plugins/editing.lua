return {
	-- ts-context-commentstring (API nueva)
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		init = function()
			-- Evita cargar el módulo viejo de nvim-treesitter y acelera el arranque
			vim.g.skip_ts_context_commentstring_module = true
		end,
		opts = {
			-- Usamos Comment.nvim para aplicar el commentstring, asi que desactivamos los autocmd propios
			enable_autocmd = false,
		},
		config = function(_, opts)
			require("ts_context_commentstring").setup(opts)
		end,
	},
	-- Comentarios (Ctrl+/ = <C-_>)
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		opts = function()
			local ok, ts_integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
			if ok then
				return {
					pre_hook = ts_integration.create_pre_hook(),
				}
			end
			return {}
		end,
		keys = {
			{
				"<C-_>",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				mode = { "n" },
				desc = "Toggle comment",
			},
			{
				"<C-_>",
				function()
					local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
					vim.api.nvim_feedkeys(esc, "nx", false)
					require("Comment.api").toggle.linewise(vim.fn.visualmode())
				end,
				mode = { "x" },
				desc = "Toggle comment",
			},
		},
	},

	-- Autopairs + integración con cmp
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function(_, opts)
			require("nvim-autopairs").setup(opts)
			local ok_cmp, cmp = pcall(require, "cmp")
			if ok_cmp then
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end,
	},

	-- Surround
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", config = true },

	-- Detectar indentación por fichero
	{
		"tpope/vim-sleuth",
		event = { "BufReadPost", "BufNewFile" },
	},
}
