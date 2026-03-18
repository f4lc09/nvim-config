local key_func = require("config.keymap_utils")
local utils = require("config.autocmds_utils")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    key_func.SetupKulalaKeymaps(args.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    key_func.SetupGoTestKeymaps(args.buf)
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
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local name = vim.api.nvim_buf_get_name(bufnr)
    local is_empty = vim.api.nvim_buf_line_count(bufnr) <= 1 and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""

    if name == "" and is_empty and vim.bo[bufnr].buftype == "" and not vim.bo[bufnr].modified then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end)
    end
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "diffview://*",
  callback = function()
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = 0 }))
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
