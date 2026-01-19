return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		plugins = { spelling = { enabled = true } },
		win = {
			no_overlap = true,
			title = true,
			padding = { 1, 2 },
		},
			spec = {
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Hunk" },
				{ "<leader>m", group = "Markdown" },
				{ "<leader>o", group = "Overseer" },
				{ "<leader>s", group = "Switch/Search" },
				{ "<leader>u", group = "UI" },
				{ "<leader>w", group = "Write" },
				{ "<leader>t", group = "Toggles" },
				{ "<leader>x", group = "Diagnostics/Trouble" },
				{ "<leader>h", group = "Harpoon" },
			},

	},
}
