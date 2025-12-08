vim.g.go_debug_log_output = ""
local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
          root_dir = function(dname) end,
          on_attach = function(client, bufnr) end,
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
