return {
  "petertriho/nvim-scrollbar",
  config = function()
    require("scrollbar").setup({
      handlers = {
        cursor = false,
      },
    })

    -- Optional: Integrations (require additional plugins like nvim-hlslens or gitsigns)
    require("scrollbar.handlers.search").setup()
    require("scrollbar.handlers.gitsigns").setup()
  end,
}
