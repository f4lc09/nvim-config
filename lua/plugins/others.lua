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
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
        go = {},
      },
    },
  },
  {
    "endaaman/vim-case-master",
  },
  {
    "trixnz/sops.nvim",
    lazy = false,
    config = function()
      require("sops").setup({
        on_attach = function(bufnr)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
          if buftype == "nofile" or filetype == "DiffviewFiles" or vim.wo.diff then
            return false
          end
          return true
        end,
      })
    end,
  },
  {
    "karb94/neoscroll.nvim",
    enabled = true,
    opts = {
      duration_multiplier = 0.6,
      easing_function = "lineaer",
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false,
      heading = {
        enabled = true,
        sign = false, -- Убирает иконки на полях
        background = false, -- Выключает фоновую заливку строки
      },
    },
  },
  { "lukas-reineke/headlines.nvim", enabled = false },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      watch_gitdir = {
        follow_files = true,
      },
    },
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "shumphrey/fugitive-gitlab.vim",
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      vim.g.fugitive_gitlab_domains = { "gitlab.wildberries.ru" }
      vim.cmd("delcommand Gbrowse")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    lzay = true,
    dependencies = {
      "leoluz/nvim-dap-go",
    },
    config = function()
      require("dap-go").setup()
    end,
  },
}
