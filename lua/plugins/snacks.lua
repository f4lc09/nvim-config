return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          hidden = true,
          ignored = true,
          exclude = {
            "**/.git",
            "**/.Session.vim",
            "**/*.pb.go",
          },
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = {
            "**/.git",
            "**/.Session.vim",
            "**/*.pb.go",
          },
        },
        explorer = {
          hidden = true,
          ignored = true,
          exclude = {
            "**/.git",
            "**/.Session.vim",
          },
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
            ["<C-o>"] = {
              function()
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
