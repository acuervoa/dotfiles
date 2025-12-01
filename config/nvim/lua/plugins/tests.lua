-- lua/plugins/tests.lua
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"olimorris/neotest-phpunit",
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Test más cercano",
		},
		{
			"<leader>tT",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Test más fichero",
		},
		{
			"<leader>tS",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Resumen tests",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open({ enter = true })
			end,
			desc = "Output test",
		},
	},
	opts = function()
		local php = require("lang.php")
		return {
			adapters = {
				require("neotest-phpunit")(php.tests.neotest.phpunit),
				},
			}
	end,
}
