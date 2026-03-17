local dap = require("dap")
local M = {}

function M.DapToggleDebug()
  if dap.session() ~= nil then
    dap.terminate()
    return
  end
  vim.cmd(":DapNew")
end

function M.DeleteBackward()
  local col = vim.fn.col(".")
  local last_col = vim.fn.col("$")

  if col >= last_col - 1 then
    vim.cmd("normal! vbd")
    return
  end
  vim.cmd("normal! vbdh")
end

return M
