return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      ---@diagnostic disable-next-line: missing-fields
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.8 },
              { id = "breakpoints", size = 0.2 },
            },
            size = 40, -- Ширина левой панели
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 1 }, -- size = 1 означает 100% доступного места в нижней панели
            },
            size = 15, -- Высота нижней панели в строках
            position = "bottom",
          },
        },
        opened = false,
      })

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
