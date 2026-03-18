local function get_short_name()
  local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_dir == "fatal: not a git repository (or any of the parent directories): .git" then
    git_dir = vim.fn.getcwd()
  end
  local project_path = (git_dir and git_dir ~= "") and git_dir or vim.fn.getcwd()
  local name = vim.fn.fnamemodify(project_path, ":t")
  local parent = vim.fn.fnamemodify(project_path, ":h:t")
  local full_name = parent .. "/" .. name
  if #full_name <= 15 then
    return full_name
  end
  local short = full_name:gsub("([^%s%a][aeiouyAEIOUY])", ""):gsub("([%a])[aeiouyAEIOUY]+", "%1")
  if #short > 16 then
    short = short:sub(1, 10) .. ".."
  end
  return short
end

local function update_tmux_window()
  if not os.getenv("TMUX") then
    return
  end
  local name = vim.g.tmux_window_name or get_short_name()
  vim.fn.jobstart({ "tmux", "rename-window", name })
end

local function SaveSessionAtGitRoot()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

  if git_root ~= "" and vim.v.shell_error == 0 then
    local session_file = git_root .. "/.Session.vim"
    vim.cmd("silent! mksession! " .. session_file)

    local current_name = vim.g.tmux_window_name

    if current_name and current_name ~= "" then
      local file = io.open(session_file, "a") -- режим "a" (append) для дозаписи
      if file then
        file:write('\nlet g:tmux_window_name = "' .. vim.g.tmux_window_name .. '"')
        file:close()
      end
    end
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

          vim.g.tmux_window_name = nil
          vim.schedule(function()
            Snacks.bufdelete.all()
            vim.api.nvim_set_current_dir(path)
            update_tmux_window()
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
      },
      sources = {
        projects = {
          layout = {
            preview = false,
          },
          confirm = function(picker, item)
            SaveSessionAtGitRoot()
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
