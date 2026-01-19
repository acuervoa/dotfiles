-- lua/lang/rust.lua
-- Configuración especifica para Rust
-- LSP (rust_analyzer), formateo, lint y tests (neotest-rust)
local M = {}

-- LSP (rust_analyzer)
M.lsp = {
	server = "rust_analyzer",
	settings = {
		["rust_analyzer"] = {
			cargo = {
				allFeatures = true,
			},
			checkOnSave = {
				command = "clippy",
			},
			imports = {
				granularity = { group = "module" },
				prefix = "self",
			},
			inlayHints = {
				enable = true,
			},
		},
	},
}

-- Formateo (conform.nvim) con rustfmt
-- Requiere 'rustfmt' en PATH (lo trae rustup por defecto)
M.format = {
	formatters = { "rustfmt" },
}

-- Lint (nvim-lint) con clippy
-- Requiere 'cargo clippy' disponible
M.lint = {
	linters = { "clippy" },
}

-- Tests (neotest-rust)
M.tests = {
	neotest = {
		rust = {
			args = { "--nocapture" },
		},
	},
}

return M
