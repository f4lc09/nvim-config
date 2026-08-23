require("bufferline")
return {
  {
    "akinsho/bufferline.nvim",
    ---@type bufferline.UserConfig
    opts = {
      options = {
        style_preset = { 3, 4 },
        buffer_close_icon = nil,
        right_trunc_marker = "→",
        left_trunc_marker = "←",
        tab_size = 0,
        sort_by = nil,
        persist_buffer_sort = false,
        truncate_names = true,
        always_show_bufferline = true,
        show_buffer_close_icons = false,
      },
    },
  },
}
