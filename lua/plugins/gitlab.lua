return {
  "harrisoncramer/gitlab.nvim",
  -- lazy = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    -- "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
    -- "nvim-tree/nvim-web-devicons", -- Recommended but not required. Icons in discussion tree.
  },
  build = function()
    require("gitlab.server").build(true)
  end, -- Builds the Go binary
  config = function()
    require("gitlab").setup({
      auth_provider = function()
        return "gitlab-JZPwd4_4F7tVuRlOUUhRcW86MQp1OmJkaQk.01.0z0rcau60", "https://gitlab.wildberries.ru", nil
      end,
    })
  end,
}
