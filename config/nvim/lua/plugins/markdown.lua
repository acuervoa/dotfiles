-- lua/plugins/markdown.lua
local env = require("config.env")

return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		enabled = not env.is_headless and not env.is_ci and not env.is_aws,
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		config = function()
			vim.g.mkdp_auto_start = 0 -- no arranca solo
			vim.g.mkdp_auto_close = 0 -- no cerrar al salir del buffer
			vim.g.mkdp_refresh_slow = 0 -- refresco normal
			vim.g.mkdp_browser = "" -- usa el navegador por defecto del sistema
		end,
		keys = {
			{
				"<leader>mp",
				function()
					vim.cmd("MarkdownPreviewToggle")
				end,
				mode = "n",
				desc = "Markdown preview (browser toggle)",
			},
		},
	},
	-- {
	-- 	"MeanderingProgrammer/render-markdown.nvim",
	-- 	main = "render-markdown",
	-- 	ft = { "markdown" }, -- se carga solo en .md
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- 	opts = {
	-- 		enabled = false,
	-- 		preset = "lazy",
	-- 		file_types = { "markdown" },
	-- 		render_modes = { "n", "c", "t" },
	-- 		latex = { enabled = false },
	-- 	},
	-- 	keys = {
	-- 		{
	-- 			"<leader>mt",
	-- 			function()
	-- 				-- Toggle render inline en el propio buffer
	-- 				vim.cmd("RenderMarkdown buf_toggle")
	-- 			end,
	-- 			desc = "Markdown render toggle (solo buffer actual)",
	-- 		},
	-- 	},
	-- },
}
