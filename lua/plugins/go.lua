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
              analyses = {},
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
}
