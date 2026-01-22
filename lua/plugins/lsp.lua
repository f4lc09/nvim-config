vim.g.go_debug_log_output = ""
local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = false,
              analyses = {
                efaceany = false,
                unusedparams = false,
                -- staticcheck = false,
                modernize = false,
                nilness = false,
              },
              ui = {
                diagnostic = {
                  efaceany = false,
                },
              },
              staticcheck = false,
              gofumpt = false,
              hints = {
                compositeLiteralFields = false,
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
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- Очищаем список линтеров для markdown
      },
    },
  },
}
