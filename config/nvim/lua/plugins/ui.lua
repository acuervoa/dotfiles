return {
	-- Tema VSCode
	{
		"Mofiqul/vscode.nvim",
		priority = 1000,
		config = function()
			local c = require("vscode.colors").get_colors()
			require("vscode").setup({
				italic_comments = true,
				group_overrides = { Cursor = { fg = c.vscDarkBlue, bg = c.vscFront, bold = true } },
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("vscode")
		end,
	},

	-- Devicons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- Bufferline
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
				offsets = {
					{ filetype = "neo-tree", text = "EXPLORER", highlight = "Directory", text_align = "center" },
				},
				separator_style = "thin",
				show_buffer_close_icons = true,
				show_close_icon = false,
				always_show_bufferline = true,
				hover = { enabled = true, delay = 200, reveal = { "close" } },
			},
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local function lsp_status()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return ""
				end
				local names = {}
				for _, client in ipairs(clients) do
					table.insert(names, client.name)
				end
				return "  " .. table.concat(names, ", ")
			end

			-- Diccionario de spell actual
			local function spell_status()
				-- Si spell está desactivado en este buffer, no mostramos nada
				if not vim.wo.spell then
					return ""
				end

				-- spelling puede ser una lista: {"es", "en"}
				local langs = vim.opt.spelllang:get() or {}
				if #langs == 0 then
					return "Spell: (none)"
				end
				-- Ejemplo: "Spell: es,en"
				return "Spell: " .. table.concat(langs, ",")
			end

			return {
				options = { theme = "vscode", globalstatus = true, component_separators = "", section_separators = "" },
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " 🔒" } } },
					lualine_x = {
						{ "diagnostics", sources = { "nvim_diagnostic" } },
						{ lsp_status },
						{ spell_status },
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			}
		end,
	},

	-- Notify
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
		init = function()
			vim.notify = require("notify")
		end,
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss notifications",
			},
		},
	},

	-- Breadcrumbs (navic)
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
		event = "BufReadPost",
		opts = { theme = "vscode", show_dirname = false, show_basename = true },
	},

	-- Indent guides (ibl v3)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = { indent = { char = "│" }, scope = { enabled = false } },
	},

	-- Dressing (inputs/select)
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = { input = { border = "rounded" }, select = { backend = { "telescope", "builtin" } } },
	},

	-- Smooth scroll
	{ "karb94/neoscroll.nvim", event = "VeryLazy", opts = {} },

	-- ToggleTerm (terminal flotante)
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = [[<C-`>]],
			direction = "float",
			float_opts = { border = "curved", winblend = 0 },
			shade_terminals = true,
		},
		keys = {
			{ "<leader>`", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal (fallback)" },
		},
	},

	-- Todo-comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TodoTelescope", "TodoQuickFix", "TodoLocList" }, -- crea comandos aunque esté Lazy
		opts = {},
	},
	-- Trouble (panel de problemas)
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"folke/todo-comments.nvim",
		},
		opts = { use_diagnostic_signs = true },
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
			{ "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
			{ "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Loclist" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
			{ "<leader>xT", "<cmd>TodoTelescope<cr>", desc = "TODOS (Telescope)" },
		},
	},
}
