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
  local session_file = vim.v.this_session

  if git_root ~= "" and vim.v.shell_error == 0 then
    session_file = git_root .. "/.Session.vim"
  end

  if session_file == "" then
    return
  end

  vim.cmd("ScopeSaveState")
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

function M.RestoreCWDFromSession()
  local session_file = vim.v.this_session
  if session_file == "" then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype

  if buftype ~= "" then
    return
  end

  if buf_name == "" then
    local session_dir = vim.fn.fnamemodify(session_file, ":p:h") .. "/"
    local current_dir = vim.fn.getcwd() .. "/"
    if not vim.startswith(current_dir, session_dir) then
      local save_ignore = vim.opt.eventignore:get()
      vim.opt.eventignore:append("all")
      pcall(vim.api.nvim_set_current_dir, session_dir)
      vim.opt.eventignore = save_ignore
    end
  end
end

function M.RestoreCWDFromSessionForce()
  local session_file = vim.v.this_session
  if session_file == "" then
    return
  end
  local session_dir = vim.fn.fnamemodify(session_file, ":p:h") .. "/"
  local save_ignore = vim.opt.eventignore:get()
  vim.opt.eventignore:append("all")
  pcall(vim.api.nvim_set_current_dir, session_dir)
  vim.opt.eventignore = save_ignore
end

local kulalaSuccess, kulala_module = pcall(require, "kulala")
function M.SetupKulalaKeymaps(bufnr)
  local map = vim.keymap.set
  map("n", "<Enter>", function()
    if kulalaSuccess and kulala_module then
      kulala_module.run()
      kulala_module.open()
      vim.defer_fn(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>l", true, false, true), "n", true)
      end, 10)
    end
  end, {
    desc = "Run HTTP request",
    buffer = bufnr,
  })
end

function M.SetupGoTestKeymaps(bufnr)
  local map = vim.keymap.set
  local filename = vim.fn.bufname(bufnr)
  if filename:match("_test.go$") then
    map("n", "<F5>", function()
      local success, dap_go_module = pcall(require, "dap-go")
      if success and dap_go_module then
        dap_go_module.debug_test()
      end
    end, {
      desc = "Debug nearest Go test",
      buffer = bufnr,
    })
  end
end

function M.LoadSession()
  local session_file = vim.fn.getcwd() .. "/.Session.vim"
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("source " .. session_file)
    vim.schedule(function()
      vim.cmd("syntax enable")
      vim.cmd("doautocmd BufRead")
      vim.cmd("set showtabline=0")
      vim.cmd("ScopeLoadState")
    end)
  end
  M.UpdateTmuxWindow()
  if vim.bo.filetype == "snacks_dashboard" then
    local bufs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())

    if #bufs > 0 then
      for _, b in ipairs(bufs) do
        print(vim.bo[b].filetype)
        if vim.bo[b].filetype ~= "snacks_dashboard" then
          vim.cmd("buffer " .. b)
          break
        end
      end
    end
  end
end

function M.ReadJar(args)
  local uri = args.file
  local buf = args.buf

  local client = vim.lsp.get_clients({
    name = "kotlin_lsp",
  })[1]

  if not client then
    return
  end

  local done = false

  client:request("workspace/executeCommand", {
    command = "decompile",
    arguments = { uri },
  }, function(err, result)
    if err or not result or not result.code then
      done = true
      return
    end

    local lines = vim.split(result.code:gsub("\r\n", "\n"), "\n", { plain = true })

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        done = true
        return
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      local ft = result.language and result.language:lower() or "kotlin"

      vim.api.nvim_set_option_value("filetype", ft, {
        buf = buf,
      })

      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly = true
      vim.bo[buf].modified = false

      done = true
    end)
  end)

  vim.wait(10000, function()
    return done
  end)
end

return M
