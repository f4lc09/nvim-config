vim.g.go_debug_log_output = ""
local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        on_new_config = function(new_config, new_root_dir)
          -- Если URI не начинается с file://, отменяем запуск gopls для этого буфера
          if not new_config.cmd_env then
            new_config.cmd_env = {}
          end
        end,
        gopls = {
          on_attach = function(client, bufnr)
            local uri = vim.uri_from_bufnr(bufnr)
            if uri:sub(1, 4) ~= "file" then
              vim.lsp.buf_detach_client(bufnr, client.id)
            end
          end,
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
