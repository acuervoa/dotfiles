-- Formateo (conform.nvim) + Lint (nvim-lint)
-- Centraliza la configuración por lenguaje (PHP, Bash, Lua, etc.)
return {
	-- Formateo
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = { "n", "v" },
				desc = "Format Buffer",
			},
		},
		config = function()
			local php = require("lang.php")
			local bash = require("lang.bash")
			local lua_lang = require("lang.lua")
			local go_lang = require("lang.go")
			local python = require("lang.python")
			local rust = require("lang.rust")

			require("conform").setup({
				formatters_by_ft = {
					php = php.format.formatters,
					[bash.ft] = bash.format.formatters,
					lua = lua_lang.format.formatters,
					go = go_lang.format.formatters,
					python = python.format.formatters,
					rust = rust.format.formatters,
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					javascriptreact = { "prettierd" },
					typescriptreact = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },
					html = { "prettierd" },
					css = { "prettierd" },
					scss = { "prettierd" },
					markdown = { "prettierd" },
					markdown_inline = { "prettierd" },
				},

				-- Autoformato en guardado, con fallback a LSP si no hay formateador externo
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_fallback = true }
				end,
			})

			-- Toggle global del formato en guardado
			vim.api.nvim_create_user_command("FormatToggle", function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
			end, { desc = "Toggle format o save (global)" })

			-- Toggle por buffer del formato en guardado
			vim.api.nvim_create_user_command("FormatToggleBuffer", function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "OFF" or "ON"))
			end, { desc = "Toggle format on save (buffer)" })
		end,
	},

	-- Lint
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local php = require("lang.php")
			local bash = require("lang.bash")
			local lua_lang = require("lang.lua")
			local go_lang = require("lang.go")
			local python = require("lang.python")
			local rust = require("lang.rust")
			local lint = require("lint")

			lint.linters_by_ft = {
				php = php.lint.linters,
				[bash.ft] = bash.lint.linters,
				lua = lua_lang.lint.linters,
				go = go_lang.lint.linters,
				python = python.lint.linters,
				rust = rust.lint.linters,
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			    json = { "jsonlint" },
			    yaml = { "yamllint" },
			    markdown = { "markdownlint" },
			    css = { "stylelint" },
			    scss = { "stylelint" },
			}

			-- require("lint").linters.phpstan.cmd = "vendor/bin/phpstan"  -- si lo usas en el repo
			local grp = vim.api.nvim_create_augroup("lint", { clear = true })
			-- vim.api.nvim_create_autocmd({ "BufEnter","BufWritePost","InsertLeave" }, { group = grp, callback = function() lint.try_lint() end })
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				group = grp,
				callback = function()
					local ft = vim.bo.filetype
					if lint.linters_by_ft[ft] ~= nil then
						lint.try_lint()
					end
				end,
			})

			-- Comando manual por si hay que invocarlo a mano
			vim.api.nvim_create_user_command("Lint", function()
				require("lint").try_lint()
			end, { desc = "Run linter for current buffer" })
		end,
	},
}
