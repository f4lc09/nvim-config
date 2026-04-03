return {
  {
    "nvim-mini/mini.map",
    config = function()
      local map = require("mini.map")

      map.setup({
        symbols = {
          scroll_line = "█",
          scroll_view = " ",
        },
        window = {
          width = 6,
          show_integration_count = false,
        },
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
          map.gen_integration.gitsigns(),
        },
      })
    end,
  },
}
