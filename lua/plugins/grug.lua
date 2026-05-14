return {
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (No Extension Filter)",
      },
    },
  },
}
