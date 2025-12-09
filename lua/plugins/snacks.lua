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
      win = {
        input = {
          keys = {
            ["<C-S-CR>"] = {
              function()
                -- Используем команду Ex-режима для принудительного переключения окна
                vim.cmd("wincmd p")
              end,
              mode = { "n", "i" },
              desc = "Focus file tree with Ctrl+Shift+Enter",
            },
          },
        },
      },
    },
  },
}
