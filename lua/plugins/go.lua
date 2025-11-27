vim.g.go_debug_log_output = ""

return {
  {
    "fatih/vim-go",
    build = ":GoInstallBinaries", -- Устанавливает необходимые бинарники Go
    ft = "go", -- Загружать только для Go файлов
    init = function()
      -- Отключает встроенный LSP vim-go, чтобы использовался nvim-lspconfig
      vim.g.go_disable_lsp = 1
    end,
    config = function()
      -- Дополнительные настройки vim-go можно добавить здесь
      -- Например, включить CodeLens (для запуска тестов над функциями)
      vim.g.go_code_lens_enabled = 1
    end,
  },
  -- Переопределяем конфигурацию gopls внутри nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                -- unusedparams = false, -- <-- Ваша настройка
              },
              staticcheck = true,
              gofumpt = false,
              hints = {
                parameterNames = false,
                variableTypes = false,
                rangeVariableTypes = false,
                compositeLiteralTypes = false,
                assignVariableTypes = false,
              },
            },
          },
        },
      },
    },
  },

  -- Если vim-go все еще установлен и активен (хотя, вероятно, уже нет)
  {
    "fatih/vim-go",
    lazy = true, -- Убедитесь, что он не загружается автоматически
    init = function()
      vim.g.go_disable_lsp = 1
    end,
  },
}
