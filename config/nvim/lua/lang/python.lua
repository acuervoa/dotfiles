-- lua/lang/python.lua
-- Configuración específica para Python
-- LSP (pyright), formateo y lint con Ruff, test con neotest-python
local M = {}

-- LSP (pyright)
M.lsp = {
	server = "pyright",
	settings = {
		pyright = {
			-- Dejamos a Ruff la parte de imports
			disableOrganizeImports = true,
		},
		python = {
			analysis = {
				-- Menos ruidoso que "strict"
				typeCheckingMode = "basic",
			},
		},
	},
}

-- Formateo (conform.nvim) usando Ruff
-- Require tener instalado el binario 'ruff' (pip, uv, pacman...)
M.format = {
	-- Orden recomendado por Ruff: fix -> format -> organize_imports
	formatters = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
}

-- Lint (nvim-lint) con Ruff
M.lint = {
	linters = { "ruff" },
}

-- Tests (neotest-python), runner pytest por defecto
M.tests = {
	neotest = {
		python = {
			dap = { justMyCode = false },
			runner = "pytest",
			-- args = { "-q" }, --para salida mas silenciosa
		},
	},
}

return M
