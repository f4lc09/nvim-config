local utils = require("config.autocmds_utils")

return {
  "folke/snacks.nvim",
  ---@type snacks.Config
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
        explorer_esc = function(picker)
          local is_explorer = picker.opts.source == "explorer"
          local mode_info = vim.api.nvim_get_mode()
          if is_explorer then
            vim.cmd("wincmd p")
            return
          end
          if mode_info.mode == "n" then
            picker:close()
            return
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end,
        explorer_up = function(picker)
          -- local item = picker:current()
          local current_root = picker:cwd()

          if not current_root then
            return
          end

          local path = vim.fn.fnamemodify(current_root, ":h")

          picker:close()

          vim.schedule(function()
            if path ~= vim.fn.getcwd() then
              local old_eventignore = vim.opt.eventignore:get()
              vim.opt.eventignore:append("all")
              vim.api.nvim_set_current_dir(path)
              vim.opt.eventignore = old_eventignore
            end

            Snacks.explorer({ cwd = path })
          end)
        end,
        cd_to_folder = function(picker)
          local item = picker:current()
          if not item then
            return
          end

          local path = item.file
          path = tostring(path)
          if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":p:h")
          end

          utils.SaveSessionAtGitRoot()
          picker:close()

          vim.schedule(function()
            if path ~= vim.fn.getcwd() then
              local old_eventignore = vim.opt.eventignore:get()
              vim.opt.eventignore:append("all")
              vim.api.nvim_set_current_dir(tostring(path))
              vim.opt.eventignore = old_eventignore
            end
            Snacks.explorer()
          end)
        end,
        copy_file_name = function(_, item)
          local target = item.file or item.path
          if not target then
            print("no target")
            return
          end

          local name = vim.fn.fnamemodify(target, ":t")
          vim.fn.setreg("+", name)
          Snacks.notify.info("Copied name: " .. name)
        end,
        open_term_in_folder = function(picker)
          -- print("Hello")
          local item = picker:current()
          if not item then
            return
          end

          local path = item.file
          path = tostring(path)
          if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":h")
          end

          -- Закрываем пикер перед открытием терминала
          picker:close()

          -- Открываем терминал в нужном CWD
          Snacks.terminal.toggle(nil, {
            cwd = path,
          })
        end,
      },
      sources = {
        projects = {
          layout = {
            preview = false,
          },
          confirm = function(picker, item)
            utils.SaveSessionAtGitRoot()
            picker:close()

            vim.g.tmux_window_name = nil

            Snacks.bufdelete.all()
            vim.schedule(function()
              if item then
                vim.fn.chdir(item.file)
              end
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
            preset = "select",
            layout = {
              -- position = "right",
              width = 0.6,
              height = 0.8,
            },
          },
        },
      },
      win = {
        list = {
          keys = {
            ["<C-f>"] = { "cd_to_folder", mode = { "n", "i" } },
            ["<C-y>"] = { "copy_file_name", mode = { "n", "i" } },
            ["<C-_>"] = { "open_term_in_folder", mode = { "n", "i" } },
          },
        },
        input = {
          keys = {
            ["<Esc>"] = {
              "explorer_esc",
              mode = { "i", "n" },
              desc = "Focus file tree with",
            },
            ["<C-_>"] = { "open_term_in_folder", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}
