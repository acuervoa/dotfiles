-- lua/plugins/tests.lua
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"olimorris/neotest-phpunit",
		"nvim-neotest/neotest-go",
		"nvim-neotest/neotest-python",
		"rouge8/neotest-rust",
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
			"<leader>ta",
			function()
				require("neotest").run.run(vim.loop.cwd())
			end,
			desc = "Test de todo el proyecto",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Resumen tests",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Output test",
		},
		{
			"<leader>tO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Toggle panel de salida",
		},
	},
	opts = function()
		local php = require("lang.php")
		local go_lang = require("lang.go")
		local python = require("lang.python")
		local rust = require("lang.rust")

		return {
			adapters = {
				require("neotest-phpunit")(php.tests.neotest.phpunit),
				require("neotest-go")(go_lang.tests.neotest.go),
				require("neotest-python")(python.tests.neotest.python),
				require("neotest-rust")(rust.tests.neotest.rust),
			},
		}
	end,
}
