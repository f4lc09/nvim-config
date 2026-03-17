local dap = require("dap")
local bufferline = require("bufferline")
local dapui = require("dapui")
local key_func = require("config.keymap_utils")

local map = vim.keymap.set
local unmap = vim.keymap.del

-- Dap Key Bindings
map("n", "<F5>", key_func.DapToggleDebug, { desc = "Dap Run/Stop Debug" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "Dap Breakpoint" })
map("n", "<C-M-j>", dap.step_over, { desc = "Dap Step Over" })
map("n", "<C-M-l>", dap.step_into, { desc = "Dap Step Into" })
map("n", "<C-M-k>", dap.continue, { desc = "Dap Step Into" })
map("n", "<C-M-h>", dap.step_out, { desc = "Dap Step Out" })
map("n", "<leader>dt", dapui.toggle, { desc = "Dap Toggle UI" })

--
-- Override common moves
map({ "n", "v" }, "<C-END>", "G", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "<C-HOME>", "gg", { noremap = true, silent = true, desc = "Go to the start of the file" })
map({ "n", "v" }, "G", "G$", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "gg", "gg^", { noremap = true, silent = true, desc = "Go to the start of the file" })

--
-- Paste Commands
map("n", "p", function()
  vim.cmd("normal! p")
  LazyVim.format()
end, { silent = true })

map("n", "P", function()
  vim.cmd("normal! P")
  LazyVim.format()
end, { silent = true })

map("x", "p", function()
  vim.cmd("normal! p")
  LazyVim.format()
end, { silent = true })

map("x", "P", function()
  vim.cmd("normal! P")
  LazyVim.format()
end, { silent = true })

map({ "n", "v" }, "<leader>p", function()
  vim.cmd("normal! o")
  vim.cmd("normal! P")
  LazyVim.format()
end, { silent = true, desc = "Paste in new line" })

map({ "n", "v" }, "<C-p>", function()
  vim.cmd("normal! O")
  vim.cmd("normal! P")
  vim.cmd("w")
end, { silent = true, desc = "Paste in new line" })

--
-- Line joining
map({ "n" }, "L", "J", { noremap = true })
map({ "n" }, "H", "kJ", { noremap = true })
map({ "n" }, "K", "k", { noremap = true })
map({ "n", "v", "x" }, "J", "j", { noremap = true })
map({ "n", "v", "x" }, "K", "k", { noremap = true })

--
-- Buffer cycling
map({ "n", "v" }, "<leader>bf", function()
  bufferline.cycle(1)
end, { silent = true, desc = "Next buffer" })
map({ "n", "v" }, "<leader>bb", function()
  bufferline.cycle(-1)
end, { silent = true, desc = "Previous buffer" })

map("n", "a", key_func.SmartInsertOnEmptyLine, {
  noremap = true,
  expr = true,
  desc = "Smart indent on empty line",
})

--
-- Lazygit Toggling
local Terminal = require("toggleterm.terminal").Terminal
local lazygit
function ToggleLazygit()
  lazygit.dir = vim.fn.getcwd()
  lazygit:toggle()
end
lazygit = Terminal:new({
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
      "t",
      "<C-l><C-g>",
      [[<C-\><C-n><cmd>lua ToggleLazygit()<CR>]],
      { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      term.bufnr,
      "n",
      "<C-l><C-g>",
      [[<cmd>lua ToggleLazygit()<CR>]],
      { noremap = true, silent = true }
    )
    vim.schedule(function()
      vim.cmd("startinsert!")
    end)
  end,
})

map("n", "<C-l><C-g>", "<cmd>lua ToggleLazygit()<CR>", { noremap = true, silent = true })
unmap("n", "<leader>l")
map("t", "<C-c><C-c>", [[<C-\><C-n>:bd!<CR>]], { desc = "Убить терминал" })
vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.timeoutlen = 175 -- Даем себе 2 секунды на нажатие <C-q><C-q>
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  pattern = "*",
  callback = function()
    vim.opt_local.timeoutlen = 1000 -- Возвращаем стандартное значение
  end,
})
map("i", "<A-d>", "<C-o>dw", { noremap = true })
map({ "v", "x" }, "$", "g_", { noremap = true })

-- Fix yanking
map({ "n" }, "x", "d", { noremap = true, desc = "Закрыть терминал и убить процесс" })
map({ "n" }, "<BS>", '"_cl<Esc>', { noremap = true, desc = "Удалить символ влево" })
map({ "n" }, "<delete>", '"_x', { noremap = true, desc = "Удалить символ влево" })
map({ "n" }, "db", key_func.DeleteBackward, { noremap = true, desc = "Удалить слово назад" })
map("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })
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

unmap("n", "<leader>e")
unmap("n", "<leader>E")
unmap("n", "<C-/>")

map("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Explorer Snacks (Root Dir)" })
map("n", "<leader>E", function()
  Snacks.picker.explorer()
end, { desc = "Snacks Picker Explorer" })
vim.keymap.set("n", "<C-_>", function()
  Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal" })

map("x", "<leader>gB", "<cmd>GBrowse<cr>", { noremap = true, silent = true })
map("n", "<leader>lsr", "<cmd>LspRestart<cr>", { noremap = true, silent = true })
map("v", "<leader>ss", function()
  vim.cmd('normal! "hy')
  local raw_text = vim.fn.getreg("h")
  local escaped_text = raw_text:gsub("([%[%]%%^%*%./%-$])", "\\%1")
  local command = string.format(
    ":%ss/%s/%s/g%s",
    "%",
    escaped_text,
    escaped_text,
    vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
  )

  vim.api.nvim_feedkeys(command, "n", false)
end, { desc = "Substitute current selection" })
