-- lua/lang/_template_lang.lua
-- Plantilla base para un nuevo lenguaje

local M = {}

-- LSP
M.lsp = {
	server = "server.name",
	settings = {
		-- config especifica del servidor
	},
}

-- Formateo (conform.nvim)
-- table sencilla con orden de preferencia de formatters
M.format = {
	formatters = { "formatter1", "formatter2" },
}

-- Lint (nvim-lint)
M.lint = {
	linters = { "linter1", "linter2" },
}

-- Tests (neotest / otros)
M.tests = {
	neitest = {
		-- por ejemplo, adapter config
		-- go = { ... },
	},
}

-- Tasks (Overseer)
M.tasks = {
	overseer = {
		-- plantillas para overseer.register_template(...)
	},
}

return M
