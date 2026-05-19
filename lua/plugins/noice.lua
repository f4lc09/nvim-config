return {
  {
    "folke/noice.nvim",
    opts = {
      messages = {
        view_error = "notify",
        view_warn = "notify",
      },
      routes = {
        {
          filter = {
            any = {
              { find = "mini.map" },
              { find = "Invalid buffer id" },
              { find = "diagnostic.lua" },
              { find = "Terminal exited with code %-1" },
              { find = "Check for any errors" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            find = "%d+L, %d+B",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            find = "gopls: 0: getting file for InlayHint",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            find = "buffers deleted",
          },
          opts = { skip = true },
        },
      },
    },
  },
}
