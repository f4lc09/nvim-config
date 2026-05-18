return {
  "dense-analysis/ale",
  ft = "go",
  config = function()
    vim.g.ale_lint_on_insert_leave = 1
    vim.g.ale_lint_on_buf_write = 1
    vim.g.ale_echo_cursor = 0
    vim.g.ale_linters = {
      go = { "golangci-lint" },
    }
    vim.g.ale_go_golangci_lint_executable = "/home/falcon/go/bin/golangci-lint"
    vim.g.ale_go_golangci_lint_options = "--config=/home/falcon/.config/nvim/.golangci.yml ./..."
    vim.g.ale_go_golangci_lint_use_json = 0
  end,
}
