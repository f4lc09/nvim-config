vim.o.showtabline = 2
vim.opt.showtabline = 2

require("config.lazy")

vim.opt.langmap =
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчняж;abcdefghijklmnopqrstuvwxyz:"

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

local function SaveSessionAtGitRoot()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

  if git_root ~= "" and vim.v.shell_error == 0 then
    local session_file = git_root .. "/.Session.vim"
    vim.cmd("silent! mksession! " .. session_file)
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
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
  end,
})
vim.o.wrap = true
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http" }, -- Add the file types you want to disable here
  callback = function()
    vim.b.autoformat = false
  end,
})
require("mini.pairs").setup({
  -- Удаляем стандартный маппинг Enter из MiniPairs,
  -- чтобы он не конфликтовал с настройками cmp или Blink
  mappings = {
    ["<CR>"] = nil, -- Устанавливаем в nil, чтобы отключить
  },
  -- ... другие настройки ...
})

vim.opt.shada = [[!,'2000,<50,s10,h]]
