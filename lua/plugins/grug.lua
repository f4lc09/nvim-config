return {
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({
            transient = true,
            prefills = {
              filesFilter = nil,
              flags = "-F --multiline",
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (No Extension Filter)",
      },
    },
  },
}
