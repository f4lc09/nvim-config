return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
          auto_close = true,
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
