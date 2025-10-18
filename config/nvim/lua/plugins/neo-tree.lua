return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = { "nvim-lua/plenary.nvim","nvim-tree/nvim-web-devicons","MunifTanjim/nui.nvim" },
  cmd = "Neotree",
  keys = {
    { "<C-b>", "<cmd>Neotree toggle left<cr>", desc = "Explorer (toggle)" },
    { "<leader>e", "<cmd>Neotree focus left<cr>", desc = "Explorer focus" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    sort_case_insensitive = true,
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      filtered_items = { hide_dotfiles = false, hide_gitignored = false },
    },
    window = {
      position = "left",
      width = 35,
      mappings = { ["<space>"]="none", ["o"]="open", ["<cr>"]="open", v="open_vsplit", s="open_split", t="open_tabnew" }
    },
  }
}
