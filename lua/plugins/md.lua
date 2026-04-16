return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false,
      heading = {
        enabled = true,
        sign = false, -- Убирает иконки на полях (если бесят)
        background = false, -- Выключает фоновую заливку строки
      },
    },
  },
  { "lukas-reineke/headlines.nvim", enabled = false },
}
