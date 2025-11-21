-- lua/plugins/makdown.lua
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		main = "render-markdown",
		ft = { "markdown" }, -- se carga solo en .md
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			file_types = { "markdown" },
		},
		keys = {
			{
				"<leader>mp",
				function()
					-- Preview renderizado en una ventana al lado
					vim.cmd("RenderMarkdown preview")
				end,
				desc = "Markdown preview (split)",
			},
			{
				"<leader>mt",
				function()
					-- Toggle render inline en el propio buffer
					vim.cmd("RenderMarkdown toggle")
				end,
				desc = "Markdown render toggle (inline)",
			},
		},
	},
}
