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
}
