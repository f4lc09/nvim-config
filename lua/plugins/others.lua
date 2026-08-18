return {
  {
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
  },
  {
    "19bischof/nvim-ansible-vault",
    config = function()
      require("ansible-vault").setup({
        vault_password_file = "/home/falcon/Desktop/ansible-vault-pass",
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = {},
      },
    },
  },
  { "folke/persistence.nvim", enabled = false },
  {
    "folke/trouble.nvim",
    opts = {
      win = {
        wo = {
          wrap = true,
        },
      },
    },
  },
  {
    -- "catppuccin/nvim",
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("onedark")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        disable = { "markdown" },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },
}
