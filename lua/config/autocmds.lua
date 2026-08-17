local utils = require("config.autocmds_utils")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    utils.SetupKulalaKeymaps(args.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    utils.SetupGoTestKeymaps(args.buf)
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "BufWinEnter", "LspAttach" }, {
  group = vim.api.nvim_create_augroup("UserBufferRoot", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    local root = utils.FindGoProjectRoot()
    if root and root ~= "" then
      vim.api.nvim_set_current_dir(root)
    end
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "json", "rest", "graphql" },
  command = "set conceallevel=0",
})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    openProject()
  end,
})
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("AutoSessionGitRoot", { clear = true }),
  callback = utils.SaveSessionAtGitRoot,
})
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    openProject()
  end,
})

function openProject()
  local session_file = vim.fn.getcwd() .. "/.Session.vim"
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("source " .. session_file)
    vim.schedule(function()
      vim.cmd("syntax enable")
      vim.cmd("doautocmd BufRead")
      vim.cmd("set showtabline=2")
    end)
  end
  utils.UpdateTmuxWindow()
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

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "yaml", "kotlin" },
  callback = function()
    vim.b.autoformat = false
  end,
})
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    local pane = os.getenv("TMUX_PANE")
    if pane then
      os.execute("tmux set-window-option -t " .. pane .. " automatic-rename on")
    end
  end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*/secrets/**/*enc*.yaml",
  callback = function(args)
    if not vim.b[args.buf].sops_first_open_done then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_win_set_cursor(0, { 1, 0 })

          vim.b[args.buf].sops_first_open_done = true
        end
      end)

      vim.b[args.buf].autoformat = false
    end
  end,
})
vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.timeoutlen = 175
  end,
})
vim.api.nvim_create_autocmd("TermLeave", {
  pattern = "*",
  callback = function()
    vim.opt_local.timeoutlen = 1000
  end,
})

local visual_timer = nil

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:[vV\x16]*",
  callback = function()
    if visual_timer then
      visual_timer:stop()
    end

    visual_timer = vim.defer_fn(function()
      local mode = vim.api.nvim_get_mode().mode
      if mode:find("[vV\x16]") then
        vim.api.nvim_set_hl(0, "Normal", { bg = "#2c323c", force = true })
        vim.api.nvim_set_hl(0, "Visual", { bg = "#121417", bold = true, force = true })
        vim.cmd("redraw")
      end
      visual_timer = nil
    end, 20)
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV\x16]*:*",
  callback = function()
    if visual_timer then
      visual_timer:stop()
      visual_timer = nil
    end

    vim.schedule(function()
      local mode = vim.api.nvim_get_mode().mode
      if not mode:find("[vV\x16]") then
        vim.api.nvim_set_hl(0, "Normal", { link = "Normal" })
        vim.cmd("colorscheme " .. vim.g.colors_name)
        vim.cmd("redraw")
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    for _, a in ipairs(vim.api.nvim_get_autocmds({ event = "CursorMoved" })) do
      if (a.group_name == "trouble.section.lsp.document_symbols.1" or a.group_name == "snacks_scroll") and a.id then
        vim.api.nvim_del_autocmd(a.id)
      end
    end
  end,
})

local group = vim.api.nvim_create_augroup("SessionCwdRestore", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete" }, {
  group = group,
  callback = function()
    vim.schedule(utils.RestoreCWDFromSession)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.opt.guicursor = "a:ver20"
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      return
    end

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local trailing_lines = vim.api.nvim_buf_get_lines(0, current_line, -1, false)

    for _, line in ipairs(trailing_lines) do
      local clean_line = line:gsub("%s", "")
      if #clean_line > 0 then
        return
      end
    end

    vim.defer_fn(function()
      vim.cmd("startinsert")
      vim.opt.guicursor = "v:hor20-Cursor,i:ver25,t:ver25,c:ver20"
    end, 10)
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    if string.find(vim.bo.filetype, "kulala_ui") then
      local win_id = vim.api.nvim_get_current_win()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win_id) then
          pcall(function()
            vim.api.nvim_win_close(win_id, false)
          end)
        end
      end)
    end
  end,
})
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = { "jar://*", "jrt://*" },
  callback = function(args)
    local uri = args.file
    local buf = args.buf

    local client = vim.lsp.get_clients({
      name = "kotlin_lsp",
    })[1]

    if not client then
      vim.notify("kotlin_lsp client not found", vim.log.levels.ERROR)
      return
    end

    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    vim.bo[buf].swapfile = false
    vim.bo[buf].buftype = "nofile"

    local done = false

    client:request("workspace/executeCommand", {
      command = "decompile",
      arguments = { uri },
    }, function(err, result)
      if err then
        vim.schedule(function()
          vim.notify(vim.inspect(err), vim.log.levels.ERROR)
        end)

        done = true
        return
      end

      if not result or not result.code then
        done = true
        return
      end

      local lines = vim.split(result.code:gsub("\r\n", "\n"), "\n", { plain = true })

      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          done = true
          return
        end

        vim.bo[buf].modifiable = true

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        vim.bo[buf].syntax = "java"
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true
        vim.bo[buf].modified = false

        done = true
      end)
    end)

    vim.wait(10000, function()
      return done
    end)
  end,
})
