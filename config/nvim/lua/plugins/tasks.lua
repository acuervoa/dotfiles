-- lua/plugins/tasks.lua
-- Overseer: tareas por lenguaje (PHP, Go, Python, Rust ...) orquestadas desde lang/*
return {
	"stevearc/overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
	keys = {
		{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle task list" },
		{
			"<leader>or",
			function()
				require("overseer").run_template()
			end,
			desc = "Overseer: run template",
		},
	},
	opts = {
		-- Estrategia genérica: terminal flotante.
		strategy = "terminal",
		task_list = {
			direction = "bottom",
			min_height = 10,
			max_height = 20,
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		-- Helper: registrar plantillas de un módulo lang.*
		local function register_lang_tasks(lang)
			local ok, mod = pcall(require, "lang." .. lang)
			if not ok or not mod.taks or not mod.tasks.overseer then
				return
			end

			for _, template in ipairs(mod.tasks.overseer) do
				overseer.register_template(template)
			end
		end

		-- Añadimos los lenguajes con tasks propios
		for _, lang in ipairs({ "php" }) do
			register_lang_tasks(lang)
	end
end,
}




