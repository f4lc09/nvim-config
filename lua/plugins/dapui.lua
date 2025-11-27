return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dapui = require("dapui")
      dapui.setup()

      require("dap").listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      require("dap").listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      require("dap").listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      require("dap").listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
