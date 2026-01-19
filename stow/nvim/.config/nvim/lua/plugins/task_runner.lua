-- Task runner / Overseer + Harpoon
return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer: run task" },
      { "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Overseer: build task" },
    },
    opts = {
      templates = { "builtin" },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      return {
        { "<leader>ha", function() harpoon:list():add() end, desc = "Harpoon add" },
        { "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon menu" },
        { "<leader>h1", function() harpoon:list():select(1) end, desc = "Harpoon 1" },
        { "<leader>h2", function() harpoon:list():select(2) end, desc = "Harpoon 2" },
        { "<leader>h3", function() harpoon:list():select(3) end, desc = "Harpoon 3" },
        { "<leader>h4", function() harpoon:list():select(4) end, desc = "Harpoon 4" },
      }
    end,
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })
    end,
  },
}
