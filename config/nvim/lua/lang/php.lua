-- lua/lang/php.lua
-- Configuración especifica para PHP (LSP, formateo, lint, tests, etc.)
-- Objetivo: centralizar todo lo propio de PHP en un único módulo.

local env = require("config.env")

local M = {}

-- LSP (intelephense)
M.lsp = {
  server = "intelephense",
  settings = {
    files = { maxSize = 5000000 },
    -- Desacrivamos el formateo del LSP porque usamos herramientas externas (conform)
    format = { enable = false },
  },
}

-- Formateo (conform.nvim)
M.format = {
  -- Orden de preferencia: primero Pint (si existe en el proyecto), luego php-cs-fixer
  formatters = { "pint", "php_cs_fixer" },
}

-- Lint (nvim-lint)
M.lint = {
  linters = { "phpstan" },
}

-- Tests (neotest-phpunit)
--
local function phpunit_cmd()
  if env.is_aws then
    return { "php", "vendor/bin/phpunit" }
  end

  if env.is_wsl then
    return { "docker", "compose", "exec", "php" ,"php", "vendor/bin/phpunit" }
  end

  if env.is_desktop_linux then
    return { "docker", "compose", "exec", "php" ,"php", "vendor/bin/phpunit" }
  end

  -- Fallback
  return { "php", "vendor/bin/phpunit" }
end

M.tests = {
  neotest = {
    phpunit = {
      phpunit_cmd = phpunit_cmd,
    },
  },
}

--
-- Tasks (Overseer) - flujos largos via mise
--


-- helper: sólo activa plantillas si es un proyecto con composer + mise
local function is_php_mise_project()
  return vim.fn.filereadable("composer.json") == 1 and vim.fn.filereadable(".mise.toml") == 1
end

M.tasks = {
  overseer = {
		-- Plantilla: test (phpunit via mise+docker)
		{
			name = "PHP: test (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "test" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = {
				callback = is_php_mise_project },
			tags = { "php", "test" },
			priority = 50,
		},

		-- Plantilla: QA completa (phpunit + phpstan + pint) (mise run qa)
		{
			name = "PHP: qa (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "qa" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = {
				callback = is_php_mise_project },
			tags = { "php", "qa" },
			priority = 40,
		},

		-- Plantilla: sólo pint
		{
			name = "PHP: pint (mise)",
			builder = function()
				return {
					cmd = { "mise", "run", "pint" },
					cwd = vim.fn.getcwd(),
					components = { "default" },
				}
			end,
			condition = { callback = is_php_mise_project },
			tags = { "php", "format" },
			priority = 30,
		},

		-- Debug: suite completa con Xdebug (mise run test_debug)
	  {
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
		},

		-- Debug: test del buffer actual (devivado a tests/...Test.php)
    {
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
		},
  },
}

return M
