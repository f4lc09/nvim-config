return {
  "dense-analysis/ale",
  -- Ensure it loads for Go files
  ft = "go",
  config = function()
    -- Global settings for ALE can be set using vim.g
    -- This example sets ALE to lint when you leave insert mode or write the buffer
    vim.g.ale_lint_on_insert_leave = 1
    vim.g.ale_lint_on_buf_write = 1
    vim.g.ale_echo_cursor = 0
    -- Set the specific linters for the 'go' filetype
    vim.g.ale_linters = {
      go = { "golangci-lint" },
    }
    -- Optional: Use JSON output for more accurate parsing (default behavior in recent ALE versions)
    vim.g.ale_go_golangci_lint_options = "--config=/home/falcon/.config/nvim/.golangci.yml"
    vim.g.ale_go_golangci_lint_use_json = 1
    -- Optional: configure how golangci-lint runs, e.g., to lint the package by default
    -- The specific options for the linter can be set like this:
    -- vim.g.ale_go_golangci_lint_options = "--some-option"

    -- ALE sends diagnostics to Neovim's built-in diagnostics system by default in newer versions
  end,
}
