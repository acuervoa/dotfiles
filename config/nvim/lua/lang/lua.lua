-- lua/lang/lua.lua
-- Configuración especifica para Lua (sobre todo Lua de Neovim)
local M = {}

-- LSP (lua_ls)
M.lsp = {
	server = "lua_ls",
	settings = {
		Lua = {
			runtime = {
				-- Neovim usa LuaJIT
				version = "LuaJIT",
			},
			diagnostics = {
				-- Para que no se queje de 'vim'
				globals = { "vim" },
			},
			workspace = {
				-- No preguntar por third-party libs, y conocer el runtime de Neovim
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
			telemetry = {
				-- No enviar telemetría
				enable = false,
			},
			hint = {
				-- Inlay hints activables desde el keymap
				enable = true,
			},
		},
	},
}

-- Formateo (conform.nvim)
-- Requiere tener 'stylua' en PATH (o instalable via Mason)
M.format = {
	formatters = { "stylua" },
}

-- Lint (nvim-lint)
-- Opcional: si hay 'luacheck', se usará; si no, no hará nada
M.lint = {
	linters = { "luacheck" },
}

-- No tests
M.tests = {}

return M
