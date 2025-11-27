local dap = require("dap")
local map = vim.keymap.set
map("n", "<F5>", function()
  if dap.session() ~= nil then
    dap.continue()
  else
    vim.cmd(":DapNew")
  end
end, { desc = "Run Go Debug" })

map("n", "<C-M-j>", function()
  dap.step_over()
end, { desc = "Dap Step Over" })

map("n", "<F9>", function()
  dap.toggle_breakpoint()
end, { desc = "Dap Breakpoint" })

vim.keymap.set("n", "<F12>", function()
  vim.lsp.buf.definition()
end, { desc = "Go To Declaration", silent = true })

local function setup_http_keymaps(bufnr)
  if vim.bo[bufnr].filetype ~= "http" then
    return
  end

  local map = vim.keymap.set("n", "<Enter>", function()
    if require("kulala") ~= nil then
      require("kulala").run()
    end
  end, { desc = "Run HTTP request" })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    setup_http_keymaps(args.buf)
  end,
})
