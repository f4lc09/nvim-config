return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "mason.nvim" },
  opts = function()
    local nls = require("null-ls")
    return {
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
      sources = {
        -- bash
        nls.builtins.formatting.shfmt,
        -- lua
        nls.builtins.formatting.stylua,
        -- python
        nls.builtins.diagnostics.flake8,
        nls.builtins.formatting.autoflake,
      },
    }
  end,
}
