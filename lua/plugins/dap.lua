-- ~/.config/nvim/lua/plugins/dap.lua

return {
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
