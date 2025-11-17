return {
  "fatih/vim-go",
  ft = "go", -- Load only for Go file types
  build = ":GoInstallBinaries", -- Execute this command after installation
  config = function()
    -- Optional: Add any vim-go specific configuration here
    -- For example:
    -- vim.g.go_fmt_autosave = 1
  end,
}
--  opts = {
--    inlay_hints = {
--      enabled = false,
--    },
