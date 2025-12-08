vim.g.go_debug_log_output = ""
local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          root_dir = util.root_pattern("go.mod"),
          settings = {
            gopls = {
              analyses = {
                -- unusedparams = false,
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
}
