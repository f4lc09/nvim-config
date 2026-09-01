local cmd_utils = require("config.utils.autocmds")
local key_utils = require("config.utils.keymaps")

local grep_history = {}
local grep_index
local files_history = {}
local other_history = {}
local history_limit = 5

local grep_source_cfg = {
  layout = {
    layout = {
      box = "horizontal",
      fulscreen = true,
      {
        box = "vertical",
        border = "rounded",
        {
          win = "input",
          height = 1,
          border = "bottom",
        },
        { win = "list", border = "none" },
        { win = "preview", height = 0.5, border = "top" },
      },
    },
  },
  on_show = function(picker)
    local picker_name = picker.opts.source
    if picker_name == "grep" then
      grep_index = nil
    elseif picker_name == "files" then
      return
    else
      return
    end
  end,
  confirm = function(picker, _)
    local current_input = picker:filter().search or ""

    local history
    local picker_name = picker.opts.source
    if picker_name == "grep" then
      history = grep_history
    elseif picker_name == "files" then
      history = files_history
    else
      history = other_history
    end

    if history[#history] == current_input then
      picker:action("edit")
      return
    end

    table.insert(history, current_input)
    if #history > history_limit then
      local start_index = #history - (history_limit - 1)
      history = table.move(history, start_index, #history, 1)
      for i = (history_limit + 1), #history do
        history[i] = nil
      end
    end

    picker:action("edit")
  end,
  hidden = true,
  ignored = true,
  exclude = {
    "**/.git",
    "**/.Session.vim",
    "**/*.pb.go",
    "**/.venv",
  },
}

return {
  "folke/snacks.nvim",
  keys = {
    -- { "<leader>fp", false }, ---@type snacks.Config
    {
      "<leader>fp",
      function()
        Snacks.picker.projects({
          win = {
            input = {
              keys = {
                ["<C-k>"] = { "do_nothing", mode = { "i", "n" } },
                ["<C-j>"] = { "cycle_win_backward", mode = { "i", "n" } },
              },
            },
            list = {
              keys = {
                ["<C-j>"] = { "cycle_win_backward", mode = { "i", "n" } },
                ["<C-k>"] = { "cycle_win", mode = { "i", "n" } },
              },
            },
            preview = {
              keys = {
                ["<C-k>"] = { "cycle_win", mode = { "i", "n" } },
                ["<C-j>"] = { "do_nothing", mode = { "i", "n" } },
              },
            },
          },
        })
        vim.wait(100)
      end,
      desc = "Projects",
    },
    { "<leader>sR", false },
    {
      "<leader>sr",
      function()
        Snacks.picker.resume()
      end,
    },
  },
  opts = {
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    terminal = {
      auto_insert = false,
      start_insert = true,
    },
    explorer = {
      diagnostics = false,
      replace_netrw = true,
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
        history_up = function(picker, _)
          local history
          local index
          local picker_name = picker.opts.source
          if picker_name == "grep" then
            history = grep_history
            if not grep_index then
              grep_index = #history
            elseif grep_index > 1 then
              grep_index = grep_index - 1
            end
            index = grep_index
          elseif picker_name == "files" then
            return
            -- history = files_history
          else
            return
            -- history = other_history
          end

          if not picker.input or not index or not history then
            return
          end

          picker.input:set("", history[index])
        end,
        history_down = function(picker, _)
          local history
          local index
          local picker_name = picker.opts.source
          if picker_name == "grep" then
            history = grep_history
            if not grep_index then
              return
            elseif grep_index < #history then
              grep_index = grep_index + 1
            elseif grep_index == #history then
              grep_index = nil
              picker.input:set("", "") -- туду: вовращать оригинальное значение?
            end
            index = grep_index
          elseif picker_name == "files" then
            return
            -- history = files_history
          else
            return
            -- history = other_history
          end

          if not picker.input or not index then
            return
          end

          picker.input:set("", history[index])
        end,
        do_nothing = function() end,
        cycle_win_backward = function(picker)
          local wins = { picker.input.win.win, picker.preview.win.win, picker.list.win.win }
          if type(vim.g.snacks_picker_cycle_win) == "number" then
            table.insert(wins, 3, vim.g.snacks_picker_cycle_win)
          end
          wins = vim.tbl_filter(function(w)
            return vim.api.nvim_win_is_valid(w)
          end, wins)
          local win = vim.api.nvim_get_current_win()
          local idx = 1
          for i, w in ipairs(wins) do
            if w == win then
              idx = i
              break
            end
          end
          win = wins[(idx - 2) % #wins + 1]
          vim.api.nvim_set_current_win(win)
        end,
        restore_session_cwd = function(picker)
          cmd_utils.RestoreCWDFromSessionForce()
          picker:close()

          vim.schedule(function()
            Snacks.explorer()
          end)
        end,
        explorer_paste = function(picker, _) --[[Override]]
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

            vim.defer_fn(function()
              local Actions = require("snacks.explorer.actions")
              Actions.update(exp, { target = current_root, refresh = true })
            end, 10)
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
        close_buffers = function(_)
          vim.api.nvim_input(vim.g.mapleader .. "bo")
        end,
      },
      sources = {
        buffers = {
          format = function(item, picker)
            local icon, hl = Snacks.util.icon(item.file, "file")
            local path = item.file or item.text
            local file = vim.fn.fnamemodify(path, ":t")
            local display_path = ""

            local diff_cwds = false
            local same_file_name = false
            local cwd = key_utils.GetCWD(path)
            local dir_name = cwd:match("^.*/([^/]+)$")

            for _, other in ipairs(picker:items()) do
              local other_path = other.file or other.text
              if path ~= other_path then
                local other_cwd = key_utils.GetCWD(other_path)
                local other_dir_name = other_cwd:match("^.*/([^/]+)$")
                if other_dir_name ~= dir_name then
                  diff_cwds = true
                end

                if vim.fn.fnamemodify(other_path, ":t") == vim.fn.fnamemodify(path, ":t") then
                  same_file_name = true
                  break
                end
              end
            end

            if diff_cwds then
              display_path = dir_name
            end
            if same_file_name then
              display_path = vim.fn.fnamemodify(path, ":.:h")
            end

            local file_hl = "Normal"
            local is_modified = false

            local bufnr = vim.fn.bufnr(item.file)
            if bufnr ~= -1 then
              local main_buf = vim.api.nvim_win_is_valid(picker.main) and vim.api.nvim_win_get_buf(picker.main) or nil
              is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
              if bufnr == main_buf then
                file_hl = "SnacksPickerTitle"
              elseif vim.api.nvim_buf_is_loaded(bufnr) then
                file_hl = "SnacksDashboardKey"
              end
            end
            local ret = {}
            if is_modified then
              ret[#ret + 1] = { "● ", "DiagnosticError" }
            end
            ret[#ret + 1] = { icon .. " ", hl }
            ret[#ret + 1] = { file .. " ", file_hl }
            ret[#ret + 1] = { display_path, "SnacksPickerDir" }

            return ret
          end,
          layout = {
            preset = "vertical",
            layout = {
              width = 0.70,
              height = 0.55,
            },
          },
        },
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
            layout = {
              box = "horizontal",
              fulscreen = true,
              {
                box = "vertical",
                border = "rounded",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                { win = "preview", height = 0.5, border = "top" },
              },
            },
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
            local home_path = vim.fn.fnamemodify(path, ":~")

            local ret = {}
            ret[#ret + 1] = { item.name or vim.fn.fnamemodify(path, ":t"), "Normal" }
            ret[#ret + 1] = { " " } -- Separator
            ret[#ret + 1] = { home_path, "Directory" }
            return ret
          end,
        },
        grep = grep_source_cfg,
        grep_word = grep_source_cfg,
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
          -- focus = "input",
          hidden = true,
          ignored = true,
          include = {
            "**/.env",
            ".gitignore",
            ".gitlab-ci.yaml",
          },
          exclude = {
            "**/.git",
            "**/.Session.vim",
          },
          auto_close = true,
          layout = {
            preset = "default",
            layout = {
              box = "vertical",
              position = "float",
              row = 1,
              col = 0,
              -- col = function()
              --   return vim.o.columns - math.floor(vim.o.columns * 0.45)
              -- end,
              height = function()
                return vim.o.lines - 4
              end,
              width = 0.45,
              border = "rounded",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
          },
        },
        diagnostics = {
          layout = {
            preset = "vertical",
            layout = {
              width = 0.95,
              height = 0.95,
            },
          },
        },
      },
      win = {
        preview = {
          keys = {
            ["<C-p>"] = {
              "cycle_win",
              mode = { "i", "n" },
              desc = "Cycle windows backwards",
            },
            ["<C-n>"] = {
              "cycle_win_backward",
              mode = { "i", "n" },
              desc = "Cycle window forward",
            },
          },
        },
        list = {
          wo = {
            wrap = true,
          },
          keys = {
            ["<C-p>"] = {
              "cycle_win",
              mode = { "i", "n" },
              desc = "Cycle windows backwards",
            },
            ["<C-n>"] = {
              "cycle_win_backward",
              mode = { "i", "n" },
              desc = "Cycle window forward",
            },
            ["<C-f>"] = { "cd_to_folder", mode = { "n", "i" } },
            ["<C-y>"] = { "copy_file_name", mode = { "n", "i" } },
            ["<M-t>"] = { "open_tmux_term_in_folder", mode = { "n", "i" } },
            ["<C-_>"] = { "open_term_in_folder", mode = { "n", "i" } },
            ["<C-g>"] = { "lazygit", mode = { "n", "i" } },
            ["<leader>ba"] = { "close_buffers", mode = { "n" } },
            ["<C-r>"] = { "restore_session_cwd", mode = { "n" } },
          },
        },
        input = {
          keys = {
            ["<Up>"] = {
              "history_up",
              mode = { "i", "n" },
              desc = "History Up",
            },
            ["<Down>"] = {
              "history_down",
              mode = { "i", "n" },
              desc = "History Down",
            },
            ["<C-p>"] = {
              "cycle_win",
              mode = { "i", "n" },
              desc = "Cycle windows forward",
            },
            ["<C-n>"] = {
              "cycle_win_backward",
              mode = { "i", "n" },
              desc = "Cycle window backwards",
            },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
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
