return {
	{
		dir = "/home/acuervo/Workspace/autoskel.nvim",
		name = "autoskel.nvim",
		dev = true,

		config = function()
			require("autoskel").setup()
		end,
	},
}
