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

function M.SetupKulalaKeymaps(bufnr)
  local map = vim.keymap.set
  map("n", "<Enter>", function()
    local success, kulala_module = pcall(require, "kulala")
    if success and kulala_module then
      kulala_module.run()
    end
  end, {
    desc = "Run HTTP request",
    buffer = bufnr,
  })
end

function M.SetupGoTestKeymaps(bufnr)
  local map = vim.keymap.set
  local filename = vim.fn.bufname(bufnr)
  if filename:match("_test.go$") then
    map("n", "<F5>", function()
      local success, dap_go_module = pcall(require, "dap-go")
      if success and dap_go_module then
        dap_go_module.debug_test()
      end
    end, {
      desc = "Debug nearest Go test",
      buffer = bufnr,
    })
  end
end

function M.SmartInsertOnEmptyLine()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*$") then
    return [["_cc]]
  else
    return "a"
  end
end

return M
