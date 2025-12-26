local function SaveSessionAtGitRoot()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

  if git_root ~= "" and vim.v.shell_error == 0 then
    local session_file = git_root .. "/.Session.vim"
    vim.cmd("silent! mksession! " .. session_file)
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    notifier = {
      enabled = true,
      style = "compact",
      top_down = false,
    },
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

          SaveSessionAtGitRoot()
          picker:close()

          vim.schedule(function()
            vim.cmd("%bd!")
            vim.api.nvim_set_current_dir(path)
            Snacks.explorer()
          end)
        end,
      },
      sources = {
        projects = {
          layout = {
            preview = false,
          },
          confirm = function(picker, item)
            SaveSessionAtGitRoot()
            picker:close()
            vim.cmd("%bd!")
            vim.schedule(function()
              if item then
                vim.fn.chdir(item.file)
              end
              Snacks.explorer()
            end)
          end,
          format = function(item)
            local path = item.file or item.text
            -- Convert absolute path to home-relative (e.g., /home/user -> ~)
            local home_path = vim.fn.fnamemodify(path, ":~")

            local ret = {}
            -- Keep the default icon and name if available
            ret[#ret + 1] = { item.name or vim.fn.fnamemodify(path, ":t"), "Normal" }
            ret[#ret + 1] = { " " } -- Separator
            ret[#ret + 1] = { home_path, "Directory" }
            return ret
          end,
        },
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
            ["<C-f>"] = { "cd_to_folder", mode = { "n", "i" } },
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
