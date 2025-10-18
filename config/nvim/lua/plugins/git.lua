return {
  -- Gitsigns
  { "lewis6991/gitsigns.nvim",
    event = { "BufReadPre","BufNewFile" },
    opts = {
      signs = { add={text="│"}, change={text="│"}, delete={text="_"}, topdelete={text="‾"}, changedelete={text="~"}, untracked={text="┆"} },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, opts) opts = opts or {}; opts.buffer = bufnr; vim.keymap.set(mode, lhs, rhs, opts) end
        -- Navegación (expr + "<Ignore>")
        map("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() gs.next_hunk() end) return "<Ignore>" end, { expr = true, desc = "Next hunk" })
        map("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() gs.prev_hunk() end) return "<Ignore>" end, { expr = true, desc = "Prev hunk" })
        -- Acciones
        map("n","<leader>hs", gs.stage_hunk, { desc="Stage Hunk" })
        map("v","<leader>hs", function() gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc="Stage Hunk" })
        map("n","<leader>hr", gs.reset_hunk, { desc="Reset Hunk" })
        map("v","<leader>hr", function() gs.reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc="Reset Hunk" })
        map("n","<leader>hS", gs.stage_buffer, { desc="Stage Buffer" })
        map("n","<leader>hu", gs.undo_stage_hunk, { desc="Undo Stage Hunk" })
        map("n","<leader>hR", gs.reset_buffer, { desc="Reset Buffer" })
        map("n","<leader>hp", gs.preview_hunk, { desc="Preview Hunk" })
        map("n","<leader>hb", function() gs.blame_line({ full = true }) end, { desc="Blame Line" })
        map("n","<leader>hd", gs.diffthis, { desc="Diff This" })
        map("n","<leader>hD", function() gs.diffthis("~") end, { desc="Diff This ~" })
        map({ "o","x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc="GitSigns Select Hunk" })
      end
    }
  },

  -- LazyGit (UI)
  { "kdheepak/lazygit.nvim",
    cmd = { "LazyGit","LazyGitConfig","LazyGitCurrentFile","LazyGitFilter","LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg","<cmd>LazyGit<cr>", desc="LazyGit" } },
  },
}
