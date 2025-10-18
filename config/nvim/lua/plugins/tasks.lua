return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun","OverseerToggle" },
  keys = {
    { "<leader>ot","<cmd>OverseerToggle<cr>", desc="Toggle Tasks" },
    { "<leader>or","<cmd>OverseerRun<cr>",    desc="Run Task" },
  },
  opts = {}
}
