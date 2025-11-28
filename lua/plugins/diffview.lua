return {
  "sindrets/diffview.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
    "nvim-lua/plenary.nvim",
  },
  cmd = "DiffviewOpen",
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diff View" },
    { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Close Diff View" },
  },
  config = function()
    require("diffview").setup()
  end,
}
