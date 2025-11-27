-- bootstrap lazy.nvim, LazyVim and your plugins

-- vim.g.go_disable_lsp = 1
require("config.lazy")

vim.opt.langmap =
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчняж;abcdefghijklmnopqrstuvwxyz:"

local function find_go_project_root()
  -- Ищет вверх по иерархии файлы 'go.mod', '.git' или 'go.work'
  return require("lspconfig.util").root_pattern("go.mod", ".git", "go.work")(vim.fn.expand("%:p"))
end

-- Autocmd: при открытии любого Go-файла автоматически менять CWD
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
  pattern = { "*.go", "go.mod" },
  callback = function()
    local root = find_go_project_root()
    if root then
      -- Меняет текущий рабочий каталог Neovim на найденный корень
      vim.cmd("cd " .. root)
      -- Опционально: вывести сообщение, чтобы знать, что каталог сменился
      -- print("CWD изменен на: " .. root)
    end
  end,
})

-- Убедитесь, что настройка gopls в lspconfig использует этот же механизм поиска корня
-- Если вы используете LazyVim, этот код должен быть в вашем lua/plugins/go.lua:
require("lspconfig").gopls.setup({
  root_dir = require("lspconfig.util").root_pattern("go.mod", ".git", "go.work"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = false,
      },
      -- другие ваши настройки
    },
  },
})
require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" }, -- Принудительно использовать gofmt
  },
  -- ... другие настройки
})
