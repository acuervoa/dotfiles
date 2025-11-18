return {
	-- Mason 2.x (repo trasladado a mason-org)
	{ "mason-org/mason.nvim", cmd = "Mason", build = ":MasonUpdate", opts = {} }, -- config=true o opts={} te vale igual
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			-- servidores por nombre de lspconfig
			ensure_installed = { "intelephense", "lua_ls", "ts_ls", "html", "cssls", "jsonls" },
			-- en v2 ya no existe 'automatic_installation'; usar automatic_enable (por defecto true)
			automatic_enable = true,
		},
		dependencies = { "neovim/nvim-lspconfig" },
	},

	-- LSPConfig + API nativa 0.11
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- 0.11+: usar vim.lsp.config()/enable() (deprecado require('lspconfig').setup)
			-- Ver migra en README de lspconfig y :help news-0.11
			-- https://github.com/neovim/nvim-lspconfig
			local ok, cmp_caps = pcall(require, "cmp_nvim_lsp")
			local caps = ok and cmp_caps.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

			local function on_attach(client, bufnr)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
				end
				-- VSCode-like (sin pisar 'gr*' nativos)
				map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
				map("n", "<F12>", vim.lsp.buf.definition, "Go to Definition (F12)")
				map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
				map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
				map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")
				-- map("n","gr", vim.lsp.buf.references, "References") -- ← quitado para no tapar grn/grr/gri/gra
				map("n", "K", vim.lsp.buf.hover, "Hover")
				map("n", "<F2>", vim.lsp.buf.rename, "Rename Symbol")
				map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				-- Inlay hints
				if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					map("n", "<leader>ch", function()
						local ih = vim.lsp.inlay_hint
						ih.enable(not ih.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
					end, "Toggle Inlay Hints")
				end

				-- Breadcrumbs (navic)
				if client.server_capabilities.documentSymbolProvider then
					local ok_navic, navic = pcall(require, "nvim-navic")
					if ok_navic then
						navic.attach(client, bufnr)
					end
				end
			end

			-- Servidores
			vim.lsp.config("intelephense", {
				capabilities = caps,
				on_attach = on_attach,
				settings = { intelephense = { files = { maxSize = 5000000 }, format = { enable = false } } },
			})
			vim.lsp.config("lua_ls", {
				capabilities = caps,
				on_attach = on_attach,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
						telemetry = { enable = false },
						hint = { enable = true },
					},
				},
			})
			vim.lsp.config("ts_ls", { capabilities = caps, on_attach = on_attach })
			vim.lsp.config("html", { capabilities = caps, on_attach = on_attach })
			vim.lsp.config("cssls", { capabilities = caps, on_attach = on_attach })
			vim.lsp.config("jsonls", { capabilities = caps, on_attach = on_attach })

			-- Habilitar (0.11+)
			vim.lsp.enable({ "intelephense", "lua_ls", "ts_ls", "html", "cssls", "jsonls" })

			-- Diagnósticos
			vim.diagnostic.config({
				virtual_text = { prefix = "●", spacing = 4 },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					},
					-- resalta el número de línea según la severida
					numhl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
						[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
						[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
						[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = "always", header = "", prefix = "" },
			})
		end,
	},

	-- Outline (como VSCode)
	{
		"hedyhli/outline.nvim",
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "<leader>cs", "<cmd>Outline<cr>", desc = "Symbols Outline" },
		},
		opts = {
			outline_window = { position = "right", width = 35 },
			preview_window = { auto_preview = true },
		},
	},
}
