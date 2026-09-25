return {
  {
    "mistweaverco/kulala.nvim",
    lazy = true,
    keys = {
      { "<leader>Rs", desc = "Send request" },
      { "<leader>Ra", desc = "Send all requests" },
      { "<leader>Rb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      treesitter = {
        enable = false, -- Отключает встроенную сборку парсера силами kulala (после перехода на nvim12 была ошибка сборки)
      },
      session = {
        restore = false,
      },
      default_env = "dev",
      global_keymaps = false,
      global_keymaps_prefix = "<leader>R",
      kulala_keymaps_prefix = "",
      -- kulala_keymaps = false,
      ui = {
        default_winbar_panes = { "body", "verbose" },
        -- "headers"
        -- "script_output"
        -- "report"
        split_direction = "above",
        -- display_mode = "float",
        show_variable_info_text = false,
        default_view = "body",
        scratchpad_default_contents = {
          "###",
          "POST http://localhost:8080",
          "accept: application/json",
          "content-type: application/json",
          "",
          "{",
          '  "foo": "bar"',
          "}",
        },
      },
    },
  },
}
