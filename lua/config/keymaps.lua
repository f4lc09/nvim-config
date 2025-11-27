-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set("n", "<F5>", ":GoDebugStart<CR>", { desc = "Run Go Debug" })
local map = vim.keymap.set("n", "<F5>", function()
  -- Проверяем, существует ли активный сеанс отладки nvim-dap
  if require("dap").session() ~= nil then
    -- Если сеанс активен, пытаемся продолжить
    vim.cmd(":GoDebugContinue")
  else
    -- Если сеанс не активен, начинаем новый
    vim.cmd(":GoDebugStart")
    -- Примечание: вы не можете автоматически вызвать Continue сразу после Start в
    -- той же функции, так как Start может потребовать взаимодействия с пользователем
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
