-- lua/plugins/session.lua
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{
			"<leader>qs",
			function()
				require("persistence").load()
			end,
			desc = "Restaurar sesión",
		},
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Última sesión",
		},
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "No guardar sesión",
		},
	},
}
