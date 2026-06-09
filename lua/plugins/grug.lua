return {
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>sr",
        function()
          local buf = vim.api.nvim_create_buf(false, true)

          require("grug-far").open({
            windowCreationCommand = "buffer " .. buf,
            transient = false,
            openTargetWindow = {
              preferredLocation = "prev",
            },
            prefills = {
              filesFilter = nil,
              flags = "-F --multiline",
            },
          })
          vim.bo.buflisted = true
          vim.api.nvim_buf_set_name(0, "Grug-Far (Search)")
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (No Extension Filter)",
      },
    },
  },
}
