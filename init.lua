vim.o.showtabline = 2
vim.opt.showtabline = 2

require("config.lazy")

-- vim.opt.langmap =
--   "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчняж;abcdefghijklmnopqrstuvwxyz:"

local function find_go_project_root()
  return require("lspconfig.util").root_pattern("go.mod", "go.work")(vim.fn.expand("%:p"))
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
  pattern = { "*.go", "go.mod" },
  callback = function()
    local root = find_go_project_root()
    if root then
      vim.cmd("cd " .. root)
    end
  end,
})

require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" },
  },
})

vim.api.nvim_create_user_command("Dapui", function()
  require("dapui").toggle()
end, { desc = "Toggle nvim-dap-ui visibility", nargs = 0 })
vim.o.smartindent = false
vim.o.autoindent = false
vim.o.cindent = true

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "json", "rest", "graphql" },
  command = "set conceallevel=0",
})
vim.opt.tabstop = 4
-- vim.opt.startofline = true
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
  fg = "#4D73A3",
})
vim.o.fixendofline = false

local function get_short_name()
  local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
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
  -- Если в сессии задана g:tmux_window_name, берем её, иначе генерим короткое имя
  local name = vim.g.tmux_window_name or get_short_name()
  vim.fn.jobstart({ "tmux", "rename-window", name })
end

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = update_tmux_window,
})

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

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("AutoSessionGitRoot", { clear = true }),
  callback = SaveSessionAtGitRoot,
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
    update_tmux_window()
  end,
})
vim.o.wrap = true
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "yaml" }, -- Add the file types you want to disable here
  callback = function()
    vim.b.autoformat = false
  end,
})
require("mini.pairs").setup({
  mappings = {
    ["<CR>"] = nil,
  },
})

vim.opt.shada = [[!,'5000,<50,s10,h]]

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "diffview://*",
  callback = function()
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = 0 }))
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    if os.getenv("TMUX") then
      os.execute("tmux set-window-option automatic-rename on")
    end
  end,
})
vim.opt.shortmess:append("F")
vim.opt.shortmess:append("A")
vim.opt.swapfile = false
