local M = {}

function M.FindGoProjectRoot()
  return require("lspconfig.util").root_pattern("go.mod", "go.work")(vim.fn.expand("%:p"))
end

function M.GetShortName()
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

function M.UpdateTmuxWindow()
  if not os.getenv("TMUX") then
    return
  end
  local name = vim.g.tmux_window_name or M.GetShortName()
  vim.fn.jobstart({ "tmux", "rename-window", name })
end

function M.SaveSessionAtGitRoot()
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

return M
