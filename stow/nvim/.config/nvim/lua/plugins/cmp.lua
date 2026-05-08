-- blink.cmp — reemplaza nvim-cmp
return {
	"saghen/blink.cmp",
	version = "0.*",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	config = function(_, opts)
		require("luasnip.loaders.from_vscode").lazy_load()
		require("luasnip.loaders.from_lua").lazy_load({
			paths = vim.fn.stdpath("config") .. "/lua/snippets",
		})
		require("blink.cmp").setup(opts)
	end,
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-e>"] = { "hide", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				buffer = { min_keyword_length = 3 },
			},
		},
		completion = {
			ghost_text = { enabled = true },
			menu = {
				border = "rounded",
				draw = {
					treesitter = { "lsp" },
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = { border = "rounded" },
			},
		},
		signature = { enabled = true, window = { border = "rounded" } },
	},
}
