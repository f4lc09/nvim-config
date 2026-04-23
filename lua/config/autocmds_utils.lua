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

function M.RestoreCWDFromSession()
  -- 1. Проверяем наличие сессии
  local session_file = vim.v.this_session
  if session_file == "" then
    return
  end

  -- 2. Данные текущего буфера
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype

  -- 3. ИСКЛЮЧЕНИЯ (Щит): Если это НЕ обычный текстовый буфер, ничего не делаем.
  -- Это защищает от срабатывания в Explorer, Telescope, терминалах и т.д.
  if buftype ~= "" then
    return
  end

  -- 4. ГЛАВНОЕ УСЛОВИЕ: Если буфер не сохранен (пустое имя)
  if buf_name == "" then
    local session_dir = vim.fn.fnamemodify(session_file, ":p:h")

    -- Меняем только если путь действительно отличается
    if vim.fn.getcwd() ~= session_dir then
      local save_ignore = vim.opt.eventignore:get()
      vim.opt.eventignore:append("all")
      pcall(vim.api.nvim_set_current_dir, session_dir)
      vim.opt.eventignore = save_ignore
    end
  end
end

return M
