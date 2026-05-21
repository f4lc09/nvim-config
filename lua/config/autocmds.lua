local utils = require("config.autocmds_utils")
local key_utils = require("config.keymap_utils")

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
  callback = utils.UpdateTmuxWindow,
})
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("AutoSessionGitRoot", { clear = true }),
  callback = utils.SaveSessionAtGitRoot,
})
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
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
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "yaml" },
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
vim.api.nvim_create_autocmd("BufLeave", {
  group = vim.api.nvim_create_augroup("CleanLastNoName", { clear = true }),
  callback = function(args)
    local bufnr = args.buf

    local name = vim.api.nvim_buf_get_name(bufnr)
    local bt = vim.bo[bufnr].buftype

    local is_empty = vim.api.nvim_buf_line_count(bufnr) == 1 and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""

    if name == "" and bt == "" and is_empty and not vim.bo[bufnr].modified then
      vim.schedule(function()
        local current = vim.api.nvim_get_current_buf()

        -- если перешли в терминал, не удаляем
        if vim.bo[current].buftype == "terminal" then
          return
        end

        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end)
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
    -- vim.defer_fn(function()
    --   require("mini.map").open()
    -- end, 50)
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
