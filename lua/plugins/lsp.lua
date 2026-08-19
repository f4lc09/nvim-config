return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      on_attach = function(client, bufnr)
        pcall(vim.api.nvim_del_augroup_by_name, "DiagnosticInsertLeave:" .. bufnr .. ":ale")
        pcall(vim.api.nvim_del_augroup_by_name, "DiagnosticInsertLeave:" .. bufnr .. ":" .. client.name .. ".10.nil")
        pcall(vim.api.nvim_clear_autocmds, { buffer = bufnr, event = { "CursorHoldI", "InsertLeave" } })
        vim.lsp.set_log_level("error")
      end,
      servers = {
        ["*"] = {
          keys = {
            { "K", false },
          },
        },
        protols = {
          enabled = false,
        },
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = false,
              analyses = {
                efaceany = false,
                unusedparams = false,
                -- staticcheck = false,
                unsafeptr = false,
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
                functionTypeParameters = false,
              },
            },
          },
        },
      },
    },
  },
}
