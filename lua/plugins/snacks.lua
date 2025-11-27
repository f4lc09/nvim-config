return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          auto_close = true, -- Closes explorer when a file is opened
          -- focus = "list", -- Optionally focus the file list instead of input on open
          layout = {
            layout = {
              position = "right", -- This moves the explorer to the right
              -- You can also specify other layout options here, like width, height, etc.
              -- width = 0.3, -- Example width
            },
          },
        },
      },
      -- ... other picker options
    },
    -- ... other snacks options
  },
}
