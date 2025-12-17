return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      formatters = {
        file = {
          filename_first = true,
        },
      },
      actions = {
        cd_to_folder = function(picker)
          local item = picker:current()
          if not item then
            return
          end

          local path = item.file
          if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":p:h")
          end

          picker:close()

          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
              vim.api.nvim_buf_delete(bufnr, { force = true })
            end
          end

          vim.api.nvim_set_current_dir(path)

          print("CWD changed to: " .. path .. " (Buffers cleared)")
        end,
      },
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
        list = {
          keys = {
            ["<C-d>"] = { "cd_to_folder", mode = { "n", "i" } },
          },
        },
        input = {
          keys = {
            ["<C-o>"] = {
              function()
                vim.cmd("wincmd p")
              end,
              mode = { "n", "i" },
              desc = "Focus file tree with",
            },
          },
        },
      },
    },
  },
}
