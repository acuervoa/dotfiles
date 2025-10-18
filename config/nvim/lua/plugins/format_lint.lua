return {
  -- Formateo
  { "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = { "n","v" }, desc = "Format Buffer" },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          php = { "pint","php_cs_fixer" }, lua = { "stylua" },
          javascript = { "prettierd","prettier" }, typescript = { "prettierd","prettier" },
          json = { "prettierd","prettier" }, yaml = { "prettierd","prettier" },
          html = { "prettierd","prettier" }, css = { "prettierd","prettier" }, scss = { "prettierd","prettier" },
          markdown = { "prettierd","prettier" },
        },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      })
      vim.api.nvim_create_user_command("FormatToggle", function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
      end, {})
    end
  },

  -- Lint
  { "mfussenegger/nvim-lint",
    event = { "BufReadPre","BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { php = { "phpstan" }, javascript = { "eslint_d" }, typescript = { "eslint_d" } }
      -- require("lint").linters.phpstan.cmd = "vendor/bin/phpstan"  -- si lo usas en el repo
      local grp = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter","BufWritePost","InsertLeave" }, { group = grp, callback = function() lint.try_lint() end })
    end
  },
}
