-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set("n", "<F5>", function()
  if require("dap").session() ~= nil then
    vim.cmd(":DapContinue")
  else
    vim.cmd(":DapNew")
    -- или времени для инициализации.
  end
end, { desc = "Run Go Debug" })
--local map = vim.keymap.set("n", "<F5>", ":GoDebugStart<CR>", { desc = "Run Go Debug" })
--local map = vim.keymap.set("n", "<F5>", ":GoDebugStart<CR>", { desc = "Run Go Debug" })

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
