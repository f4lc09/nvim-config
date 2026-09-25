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
      global_keymaps = false,
      global_keymaps_prefix = "<leader>R",
      kulala_keymaps_prefix = "",
      ui = {
        split_direction = "below",
        -- display_mode = "float",
        show_variable_info_text = false,
        default_view = "body",
      },
    },
  },
}
