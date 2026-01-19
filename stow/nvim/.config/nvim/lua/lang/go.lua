-- lua/lang/go.lua
-- Configuracion especifica para Go
-- LSP (gopls), formateo, lint y tests (neotest-go)
local M = {}

M.lsp = {
	server = "gopls",
	settings = {
		gopls = {
			-- Análisis útiles para backend
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
			gofumpt = true,
		},
	},
}

-- Formateo (conform.nvim)
-- Se usará el primer formateador disponible en PATH
M.format = {
	-- Orden de preferencia:
	-- 1) gofumpt		(más estricto, recomendado)
	-- 2) goimports	(añade/quita importas)
	-- 3) gofmt			(fallback)
	formatters = { "gofumpt", "goimports", "gofmt" },
}

-- Lint (nvim-lint)
-- Require 'golangci-lint' (Mason: golangci-lint)
M.lint = {
	linters = { "golangci_lint" },
}

-- Tests (neotest-go)
M.tests = {
	neotest = {
		go = {
			-- Opciones que se pasan a neotest-go
			experimental = { test_table = true },
			args = { "-count=1", "-timeout=60s" },
		},
	},
}

return M
