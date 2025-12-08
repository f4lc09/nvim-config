-- bootstrap lazy.nvim, LazyVim and your plugins

-- vim.g.go_disable_lsp = 1
require("config.lazy")

vim.opt.langmap =
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчняж;abcdefghijklmnopqrstuvwxyz:"

local function find_go_project_root()
  return require("lspconfig.util").root_pattern("go.mod", ".git", "go.work")(vim.fn.expand("%:p"))
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

require("lspconfig").gopls.setup({
  root_dir = require("lspconfig.util").root_pattern("go.mod", ".git", "go.work"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = false,
      },
    },
  },
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
