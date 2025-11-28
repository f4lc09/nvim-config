local dap = require("dap")
local map = vim.keymap.set

-- COMMON SENSE
local function dap_step_over()
  dap.step_over()
end
local function dap_step_into()
  dap.step_into()
end
local function dap_step_out()
  dap.step_out()
end
local function dap_toggle_breakpoint()
  dap.toggle_breakpoint()
end
local function dap_new_or_continue()
  if dap.session() ~= nil then
    dap.continue()
  else
    vim.cmd(":DapNew")
  end
end
local function lsp_definition()
  vim.lsp.buf.definition()
end
local function lsp_references()
  vim.lsp.buf.references()
end
local function lsp_rename()
  vim.lsp.buf.rename()
end

map("n", "<F2>", lsp_rename, { desc = "Run Go Debug" })
map("n", "<F5>", lsp_references, { desc = "Run Go Debug" })
map("n", "<F5>", dap_new_or_continue, { desc = "Run Go Debug" })
map("n", "<F9>", dap_toggle_breakpoint, { desc = "Dap Breakpoint" })
map("n", "<F12>", lsp_definition, { desc = "Go To Declaration", silent = true })
map("n", "<C-M-j>", dap_step_over, { desc = "Dap Step Over" })
map("n", "<C-M-l>", dap_step_into, { desc = "Dap Step Into" })
map("n", "<C-M-h>", dap_step_out, { desc = "Dap Step Out" })

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
