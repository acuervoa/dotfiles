-- lua/plugins/session.lua
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{
			"<leader>Qs",
			function()
				require("persistence").load()
			end,
			desc = "Restaurar sesión",
		},
		{
			"<leader>Ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Última sesión",
		},
		{
			"<leader>Qd",
			function()
				require("persistence").stop()
			end,
			desc = "No guardar sesión",
		},
	},
}
