-- lua/plugins/search.lua
return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open()
      end,
      desc = "[S]earch & [R]eplace (grug-far)",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      mode = "n",
      desc = "[S]earch [W]ord (grug-far)",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").with_visual_selection()
      end,
      mode = "x",
      desc = "[S]earch [W]ord (grug-far)",
    },
    {
      "<leader>sp",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
      end,
      desc = "[S]earch in current file (grug-far)",
    },
  },
  opts = {},
}
