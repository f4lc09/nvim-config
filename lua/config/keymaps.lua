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
local function dap_new()
  if dap.session() ~= nil then
    dap.terminate()
    return
  end
  vim.cmd(":DapNew")
end
local function dap_continue()
  if dap.session() ~= nil then
    dap.continue()
  end
end
local function dapui_toggle()
  require("dapui").toggle()
end

map("n", "<F5>", dap_new, { desc = "Run Go Debug" })
map("n", "<F9>", dap_toggle_breakpoint, { desc = "Dap Breakpoint" })
map("n", "<C-M-j>", dap_step_over, { desc = "Dap Step Over" })
map("n", "<C-M-l>", dap_step_into, { desc = "Dap Step Into" })
map("n", "<C-M-k>", dap_continue, { desc = "Dap Step Into" })
map("n", "<C-M-h>", dap_step_out, { desc = "Dap Step Out" })
map("n", "<leader>dt", dapui_toggle, { desc = "Dap Toggle UI" })
map({ "n", "v" }, "<C-END>", "G", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "<C-HOME>", "gg", { noremap = true, silent = true, desc = "Go to the start of the file" })
map({ "n", "v" }, "G", "G$", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "gg", "gg^", { noremap = true, silent = true, desc = "Go to the start of the file" })

map("n", "p", function()
  vim.cmd("normal! p")
  vim.cmd("w")
end, { silent = true })
map("n", "P", function()
  vim.cmd("normal! P")
  vim.cmd("w")
end, { silent = true })
map("x", "p", function()
  vim.cmd("normal! p")
  vim.cmd("w")
end, { silent = true })
map("x", "P", function()
  vim.cmd("normal! P")
  vim.cmd("w")
end, { silent = true })
map({ "n", "v" }, "<leader>p", function()
  vim.cmd("normal! o")
  vim.cmd("normal! P")
  vim.cmd("w")
end, { noremap = true, silent = true, desc = "Paste in new line" })
map({ "n", "v" }, "<C-p>", function()
  vim.cmd("normal! O")
  vim.cmd("normal! P")
  vim.cmd("w")
end, { noremap = true, silent = true, desc = "Paste in new line" })

local function setup_http_keymaps(bufnr)
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    setup_http_keymaps(args.buf)
  end,
})

local function setup_go_test_keymaps(bufnr)
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    setup_go_test_keymaps(args.buf)
  end,
})
-- map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
-- map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
-- map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
-- map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map({ "n", "v" }, "<leader>bf", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
map({ "n", "v" }, "<leader>bb", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })
map("n", "<F13>", ":bnext<CR>", { silent = true })
map("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })
map("x", "<leader>gB", "<cmd>GBrowse<cr>", { noremap = true, silent = true })
map("n", "<leader>lsr", "<cmd>LspRestart<cr>", { noremap = true, silent = true })
map("v", "<leader>ss", function()
  -- Копируем выделение в регистр 'h'
  vim.cmd('normal! "hy')

  -- Экранируем спецсимволы (особенно важно для прямого слеша /)
  local raw_text = vim.fn.getreg("h")
  local escaped_text = raw_text:gsub("([%[%]%%^%*%./%-$])", "\\%1")

  -- Формируем команду: %s/текст/текст/g и двигаем курсор на 2 позиции влево (пропускаем /g)
  local command = string.format(
    ":%ss/%s/%s/g%s",
    "%",
    escaped_text,
    escaped_text,
    vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
  )

  vim.api.nvim_feedkeys(command, "n", false)
end, { desc = "Substitute current selection" })

local function smart_insert_on_empty_line()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*$") then
    return [["_cc]]
  else
    return "a"
  end
end

map("n", "a", smart_insert_on_empty_line, {
  noremap = true,
  expr = true,
  desc = "Smart indent on empty line",
})

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "none",
  },
  highlights = {
    Border = { link = "FloatBorder" },
  },
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(
      term.bufnr,
      "t", -- режим терминала
      "<C-q>",
      [[<C-\><C-n><cmd>lua _lazygit_toggle()<CR>]],
      { noremap = true, silent = true }
    )
    -- Также для нормального режима, если вы вышли из вставки
    vim.api.nvim_buf_set_keymap(
      term.bufnr,
      "n",
      "<C-q>",
      [[<cmd>lua _lazygit_toggle()<CR>]],
      { noremap = true, silent = true }
    )
    vim.schedule(function()
      vim.cmd("startinsert!")
    end)
  end,
})

function _lazygit_toggle()
  lazygit.dir = vim.fn.getcwd()
  lazygit:toggle()
end

map("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
map("n", "db", '"_dvb', { noremap = true })
vim.keymap.del("n", "<leader>l")
map("t", "<C-q>", [[<C-\><C-n>:bd!<CR>]], { desc = "Закрыть терминал и убить процесс" })
map("i", "<A-d>", "<C-o>dw", { noremap = true })
map("v", "$", "g_", { noremap = true })

-- Fix yanking
map({ "n" }, "x", '"_x', { noremap = true, desc = "Закрыть терминал и убить процесс" })
map({ "n", "v", "x", "s" }, "d", '"_d', { noremap = true, desc = "Delete without yanking", nowait = true })
map("n", "dd", '"_dd', { noremap = true, desc = "Delete line without yanking", nowait = true })
map({ "n", "x", "v", "s" }, "D", '"_D', { noremap = true, desc = "Delete without yanking", nowait = true })
map({ "x", "n", "v" }, "c", '"_c', { noremap = true, desc = "Change without yanking", nowait = true })
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
map("x", "p", "P", { noremap = true, desc = "Paste without overwriting clipboard" })

local function get_short_name()
  local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local project_path = (git_dir and git_dir ~= "") and git_dir or vim.fn.getcwd()
  local name = vim.fn.fnamemodify(project_path, ":t")
  local parent = vim.fn.fnamemodify(project_path, ":h:t")
  local full_name = parent .. "/" .. name
  if #full_name <= 15 then
    return full_name
  end
  local short = full_name:gsub("([^%s%a][aeiouyAEIOUY])", ""):gsub("([%a])[aeiouyAEIOUY]+", "%1")
  if #short > 16 then
    short = short:sub(1, 10) .. ".."
  end
  return short
end

local function update_tmux_window()
  if not os.getenv("TMUX") then
    return
  end
  local name = vim.g.tmux_window_name or get_short_name()
  vim.fn.jobstart({ "tmux", "rename-window", name })
end

function SetTmuxWindowName()
  local new_name = vim.fn.input("Имя окна tmux: ", vim.g.tmux_window_name or "")
  if new_name ~= "" then
    vim.g.tmux_window_name = new_name
    update_tmux_window()
  end
end

vim.keymap.set("n", "<leader>rn", SetTmuxWindowName, { desc = "Rename Tmux Window" })

vim.on_key(function(key)
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" or mode == "R" then
    return
  end
  if key:match("[%z\1-\127]") == nil and key:match("[а-яА-ЯёЁ]") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

    vim.notify("Смени раскладку! (Wrong language)", vim.log.levels.ERROR, {
      title = "Keyboard Layout",
      timeout = 500,
    })
  end
end)
vim.o.timeoutlen = 1000
