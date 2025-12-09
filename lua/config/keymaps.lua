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
local function dapui_toggle()
  require("dapui").toggle()
end

local function lsp_rename()
  vim.lsp.buf.rename()
end

map("n", "<F2>", lsp_rename, { desc = "Run Go Debug" })
-- map("n", "<F5>", lsp_references, { desc = "Run Go Debug" })
map("n", "<F5>", dap_new_or_continue, { desc = "Run Go Debug" })
map("n", "<F9>", dap_toggle_breakpoint, { desc = "Dap Breakpoint" })
map("n", "<C-M-j>", dap_step_over, { desc = "Dap Step Over" })
map("n", "<C-M-l>", dap_step_into, { desc = "Dap Step Into" })
map("n", "<C-M-h>", dap_step_out, { desc = "Dap Step Out" })
map("n", "<leader>dt", dapui_toggle, { desc = "Dap Toggle UI" })
map({ "n", "v" }, "<C-END>", "G", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "<C-HOME>", "gg", { noremap = true, silent = true, desc = "Go to the start of the file" })
map({ "n", "v" }, "G", "G$", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "gg", "gg^", { noremap = true, silent = true, desc = "Go to the start of the file" })
map({ "n", "v" }, "<leader>p", "o<Esc>P", { noremap = true, silent = true, desc = "Paste in new line" })
map({ "n", "v" }, "<leader>P", "O<Esc>P", { noremap = true, silent = true, desc = "Paste in new line" })

local function setup_http_keymaps(bufnr)
  vim.keymap.set("n", "<Enter>", function()
    local success, kulala_module = pcall(require, "kulala")
    if success and kulala_module then
      kulala_module.run()
    end
  end, {
    desc = "Run HTTP request",
    buffer = bufnr,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    setup_http_keymaps(args.buf)
  end,
})

local function setup_go_test_keymaps(bufnr)
  local filename = vim.fn.bufname(bufnr)
  if filename:match("_test.go$") then
    vim.keymap.set("n", "<F5>", function()
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    setup_go_test_keymaps(args.buf)
  end,
})
map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
map({ "n", "v" }, "<leader>bf", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
map({ "n", "v" }, "<leader>bb", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })
map("n", "<F13>", ":bnext<CR>", { silent = true })
map("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })

local function smart_insert_on_empty_line()
  -- Получаем содержимое текущей строки
  local line = vim.api.nvim_get_current_line()

  -- Проверяем, пуста ли строка или содержит только пробелы
  if line:match("^%s*$") then
    -- Если пуста, выполняем команду "cc" (change current line) в нормальном режиме.
    -- Это заставляет Vim пересчитать и вставить правильный отступ, как команда 'o'.
    -- "_ означает, что удаленный контент не попадет ни в один буфер обмена.
    return [["_cc]]
  else
    -- Если строка не пустая, просто работаем как обычная 'i'
    return "i"
  end
end

-- Переназначаем клавишу 'i' в нормальном режиме на нашу функцию
vim.keymap.set("n", "i", smart_insert_on_empty_line, {
  noremap = true,
  expr = true, -- expr = true позволяет функции возвращать строку команды
  desc = "Smart indent on empty line",
})
