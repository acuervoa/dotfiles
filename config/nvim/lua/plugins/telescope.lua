return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	keys = {
		{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Ctrl+P)" },
		{ "<leader>P", "<cmd>Telescope commands<cr>", desc = "Command Palette" },
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search in Workspace" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
		{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
		{ "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Notification history" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope, actions = require("telescope"), require("telescope.actions")
		telescope.setup({
			defaults = {
				prompt_prefix = "  ",
				selection_caret = " ",
				entry_prefix = "  ",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = { prompt_position = "top", preview_width = 0.55 },
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				sorting_strategy = "ascending",
				file_ignore_patterns = { "node_modules", ".git/", "vendor/" },
				mappings = {
					i = {
						["<C-n>"] = actions.move_selection_next,
						["<C-p>"] = actions.move_selection_previous,
						["<C-u>"] = false,
						["<C-d>"] = false,
						["<esc>"] = actions.close,
					},
				},
			},
			pickers = { find_files = { theme = "dropdown", previewer = false } },
			extensions = {
				["ui-select"] = { require("telescope.themes").get_dropdown() },
				fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
				notify = {},
			},
		})
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")
		pcall(telescope.load_extension, "notify")
	end,
}
