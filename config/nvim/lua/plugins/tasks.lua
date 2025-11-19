-- overseer
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

		-- helper: sólo activa plantillas si es un proyecto con composer + mise
		local function is_php_mise_project()
			return vim.fn.filereadable("composer.json") == 1 and vim.fn.filereadable(".mise.toml") == 1
		end

		-- Plantilla: test (phpunit via mise+docker)
		overseer.register_template({
			name = "PHP: test (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "test" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = {
				callback = is_php_mise_project,
			},
			tags = { "php", "test" },
			priority = 50,
		})

		-- Plantilla: QA completa (phpunit + phpstan + pint)
		overseer.register_template({
			name = "PHP: qa (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "qa" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = {
				callback = is_php_mise_project,
			},
			tags = { "php", "qa" },
			priority = 40,
		})

		-- Plantilla: sólo pint
		overseer.register_template({
			name = "PHP: pint (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "pint" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = {
				callback = is_php_mise_project,
			},
			tags = { "php", "format" },
			priority = 30,
		})

		-- Debug: suite completa
		overseer.register_template({
			name = "PHP: test (debug suite)",
			builder = function()
				return {
					cmd = { "mise", "run", "test_debug" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = { callback = is_php_mise_project },
			tags = { "php", "test", "debug" },
			priority = 60,
		})

		-- Debug: test del buffer actual
		overseer.register_template({
			name = "PHP: test (debug current file)",
			builder = function()
				-- ruta relativa al cwd
				local rel = vim.fn.expand("%")
				if rel == "" then
					vim.notify("No hay fichero asociado al buffer actual", vim.log.levels.WARN)
					return nil
				end

				-- si ya estamos en tests/, usar tal cual
				local test_path = rel
				if not rel:match("^tests/") then
					test_path = "tests/" .. test_path
				end
				if not test_path:match("Test%.php$") then
					test_path = test_path:gsub("%.php$", "Test.php")
				end

				return {
					cmd = {
						"docker",
						"compose",
						"run",
						"--rm",
						"-e",
						"XDEBUG_MODE=debug",
						"php",
						"php",
						"vendor/bin/phpunit",
						test_path,
					},
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = { callback = is_php_mise_project },
			tags = { "php", "test", "debug" },
			priority = 70,
		})
	end,
}
