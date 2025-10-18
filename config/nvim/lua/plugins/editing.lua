return {
  -- Comentarios (Ctrl+/ = <C-_>)
  { "numToStr/Comment.nvim",
    event = { "BufReadPost","BufNewFile" },
    opts = {},
    keys = {
      { "<C-_>", function() require("Comment.api").toggle.linewise.current() end, mode = { "n" }, desc = "Toggle comment" },
      { "<C-_>", function()
          local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
          vim.api.nvim_feedkeys(esc, "nx", false)
          require("Comment.api").toggle.linewise(vim.fn.visualmode())
        end,
        mode = { "x" }, desc = "Toggle comment"
      },
    }
  },

  -- Autopairs + integración con cmp
  { "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  },

  -- Surround
  { "kylechui/nvim-surround", version="*", event = "VeryLazy", config = true },

  -- TODO/FIXME destacados
  { "folke/todo-comments.nvim", event = { "BufReadPost","BufNewFile" }, dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
}
