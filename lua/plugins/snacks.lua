local cmd_utils = require("config.autocmds_utils")

return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    -- dashboard = {
    --   preset = {
    --     keys = {
    --       { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
    --       { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
    --       { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    --     },
    --   },
    -- },
    terminal = {
      auto_insert = false,
      start_insert = true,
    },
    explorer = {
      diagnostics = false,
    },
    scroll = {
      enabled = false,
    },
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
        explorer_paste = function(picker, item) --[[Override]]
          local Tree = require("snacks.explorer.tree")
          local files = vim.split(vim.fn.getreg(vim.v.register or "+") or "", "\n", { plain = true })
          files = vim.tbl_filter(function(file)
            return file ~= "" and vim.uv.fs_stat(file) ~= nil
          end, files)
          if #files == 0 then
            return Snacks.notify.warn(("The `%s` register does not contain any files"):format(vim.v.register or "+"))
          end
          local dir = picker:dir()

          local first_pasted_dst = nil
          for _, file in ipairs(files) do
            if file == dir then
              Snacks.notify.warn(string.format("Skip recursive copy: %s", file))
            else
              local dst = vim.fs.joinpath(dir, vim.fn.fnamemodify(file, ":t"))
              local dst_unique = dst
              local count = 0
              while vim.uv.fs_stat(dst_unique) do
                count = count + 1
                dst_unique = string.format("%s (copy %d)", dst, count)
              end
              Snacks.picker.util.copy_path(file, dst_unique)
              if not first_pasted_dst then
                first_pasted_dst = dst_unique
              end
            end
          end

          Tree:refresh(dir)
          Tree:open(dir)

          local Actions = require("snacks.explorer.actions")
          Actions.update(picker, { refresh = true })

          -- НАЙТИ И ОТКРЫТЬ ПАПКУ, ЕСЛИ ОНА ЗАКРЫТА
          local current_item = picker:current()
          if current_item and current_item.dir and not current_item.open then
            picker:toggle(current_item)
          end

          if first_pasted_dst then
            Actions.update(picker, { target = first_pasted_dst, refresh = true })
          end
        end,
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

            local exp = Snacks.explorer({ cwd = path, follow_file = false })
            exp:action("explorer_close_all")
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

          cmd_utils.SaveSessionAtGitRoot()
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
          local item = picker:current()
          if not item then
            return
          end

          local path = item.file
          path = tostring(path)
          if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":h")
          end

          picker:close()

          Snacks.terminal.toggle(nil, {
            cwd = path,
          })
        end,
        open_tmux_term_in_folder = function(picker)
          local item = picker:current()
          if not item then
            return
          end

          local path = item.file
          path = tostring(path)
          if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":h")
          end

          picker:close()

          os.execute("tmux split-window -v -c " .. path)
        end,
        close_buffers = function(picker)
          vim.api.nvim_input(vim.g.mapleader .. "bo")
        end,
      },
      sources = {
        projects = {
          on_show = function(picker)
            local bufnr = picker.input.win.buf
            vim.keymap.set({ "i", "n", "v" }, "<C-w>", function()
              if vim.api.nvim_get_mode().mode ~= "i" then
                return
              end
              local col = vim.fn.col(".")
              local line = vim.fn.getline(".")
              local last_col = #line
              if col >= last_col - 1 then
                vim.cmd('normal! vb"_d')
                local keycode = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
                vim.api.nvim_feedkeys(keycode, "n", false)
                return
              end
              vim.cmd('normal! vb"_d')
            end, { buffer = bufnr, nowait = true, desc = "Кастомный Ctrl+W в проектах" })
            vim.keymap.set({ "i", "n", "v" }, "<M-d>", function()
              if vim.api.nvim_get_mode().mode ~= "i" then
                return
              end
              vim.cmd('normal! vw"_d')
            end, { buffer = bufnr, nowait = true, desc = "Кастомный Ctrl+W в проектах" })
          end,
          layout = {
            preview = false,
          },
          confirm = function(picker, item)
            cmd_utils.SaveSessionAtGitRoot()
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
          format = function(item, picker)
            local ret = {}

            vim.list_extend(ret, require("snacks.picker.format").file(item, picker))
            -- if #ret >= 2 then
            --   ret[2] = { item.file }
            -- end

            while #ret > 2 do
              table.remove(ret)
            end

            return ret
          end,
          layout = {
            preset = "vertical",
            layout = {
              width = 0.95,
              height = 0.95,
            },
          },
          hidden = true,
          ignored = true,
          exclude = {
            "**/.git",
            "**/.Session.vim",
            "**/*.pb.go",
            "**/.venv",
          },
        },
        files = {
          layout = {
            preset = "vertical",
            layout = {
              width = 0.95,
              height = 0.95,
            },
          },
          hidden = true,
          ignored = true,
          exclude = {
            "**/.git",
            "**/.Session.vim",
            "**/*.pb.go",
            "**/.venv",
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
              width = 0.95,
              height = 0.95,
            },
          },
        },
      },
      win = {
        list = {
          keys = {
            ["<C-f>"] = { "cd_to_folder", mode = { "n", "i" } },
            ["<C-y>"] = { "copy_file_name", mode = { "n", "i" } },
            ["<M-t>"] = { "open_tmux_term_in_folder", mode = { "n", "i" } },
            ["<C-_>"] = { "open_term_in_folder", mode = { "n", "i" } },
            ["<C-g>"] = { "lazygit", mode = { "n", "i" } },
            ["<leader>ba"] = { "close_buffers", mode = { "n" } },
          },
        },
        input = {
          keys = {
            ["<Esc>"] = {
              "explorer_esc",
              mode = { "i", "n" },
              desc = "Focus file tree with",
            },
            ["<C-\\>"] = { "open_tmux_term_in_folder", mode = { "n", "i" } },
            ["<C-_>"] = { "open_term_in_folder", mode = { "n", "i" } },
            ["<C-g>"] = { "lazygit", mode = { "n", "i" } },
            ["<leader>ba"] = { "close_buffers", mode = { "n" } },
          },
        },
      },
    },
  },
}
