local dap = require("dap")
local dapui = require("dapui")
local utils = require("config.keymap_utils")
local lazygit = require("config.lazygit_utils")

local map = vim.keymap.set
local unmap = vim.keymap.del

-- Dap Key Bindings
map("n", "<F5>", utils.DapToggleDebug, { desc = "Dap Run/Stop Debug" })
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
map({ "n", "v" }, "<C-y>", "<cmd>%y<CR>", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "<C-v>", "ggVG", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "<M-v>", "<C-v>", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "gm", "`", { noremap = true, silent = true, desc = "Go mark" })
map("n", "v", "<Esc>v", { noremap = true, silent = true })
map("n", "<C-d>", utils.SmartScroll("down"))
map("n", "<C-u>", utils.SmartScroll("up"))

--
-- Terminal
-- Привязываем к Ctrl + / и Ctrl + _ (для Windows)
unmap("n", "<C-/>")
map({ "n", "t", "i" }, "<C-/>", utils.ToggleTerminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<C-\\>", utils.ToggleTmuxTerminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<C-_>", utils.ToggleTerminal, { desc = "Toggle Terminal" })
map({ "t" }, "<C-n>", [[<C-\><C-n>]], { desc = "Go normanl mode from terminal" })
map({ "t" }, "<C-u>", [[<C-\><C-n><C-u>]], { desc = "Go normanl mode from terminal" })
map("t", "<C-c><C-c>", [[<C-\><C-n>:bd!<CR>]], { desc = "Fast kill terminal" })

--
-- Paste Commands
map({ "v", "x" }, "p", function()
  local reg = vim.v.register
  vim.cmd('normal! "' .. reg .. "P")
  LazyVim.format()
end, { silent = true })

map({ "n" }, "p", function()
  local reg = vim.v.register
  vim.cmd('normal! "' .. reg .. "p")
  LazyVim.format()
end, { silent = true })

map({ "n", "v", "x" }, "P", function()
  local reg = vim.v.register
  vim.cmd('normal! "' .. reg .. "P")
  LazyVim.format()
end, { silent = true })

map({ "n", "v" }, "<leader>p", function()
  local reg = vim.v.register
  vim.cmd("normal! o")
  vim.cmd('normal! "' .. reg .. "P")
  LazyVim.format()
end, { silent = true, desc = "Paste in new line" })

map({ "n", "v" }, "<C-p>", function()
  local reg = vim.v.register
  vim.cmd("normal! O")
  vim.cmd('normal! "' .. reg .. "P")
  vim.cmd("w")
end, { silent = true, desc = "Paste in new line" })

--
-- Line joining
map({ "n" }, "L", "J", { noremap = true })
map({ "n" }, "H", "kJ", { noremap = true })
map({ "n", "v", "x" }, "J", "j", { noremap = true })
map({ "n", "v", "x" }, "K", "k", { noremap = true })

--
-- Wrappers
map("v", 'gw"', utils.Wrap('"', '"'), { noremap = true, desc = "Wrap" })
map("v", "gw'", utils.Wrap("'", "'"), { noremap = true, desc = "Wrap" })
map("v", "gw`", utils.Wrap("`", "`"), { noremap = true, desc = "Wrap" })
map("v", "gw{", utils.Wrap("{", "}"), { noremap = true, desc = "Wrap" })
map("v", "gw[", utils.Wrap("[", "]"), { noremap = true, desc = "Wrap" })
map("v", "gw|", utils.Wrap("|", "|"), { noremap = true, desc = "Wrap" })
map("v", "gw@", utils.Wrap("@", "@"), { noremap = true, desc = "Wrap" })
map("v", "gw:", utils.Wrap(":", ":"), { noremap = true, desc = "Wrap" })
map("v", "gw;", utils.Wrap(";", ";"), { noremap = true, desc = "Wrap" })

--
-- Fix yanking
map({ "n" }, "x", "d", { noremap = true, desc = "Закрыть терминал и убить процесс" })
map({ "n" }, "X", "Vd", { noremap = true, desc = "Закрыть терминал и убить процесс" })
map({ "n" }, "xb", utils.CutBackward, { noremap = true, desc = "Удалить слово назад" })

map({ "n", "v", "x", "s" }, "d", '"_d', { noremap = true, desc = "Delete without yanking", nowait = true })
map({ "n" }, "D", 'V"_d', { noremap = true, desc = "Delete line without yanking", nowait = true })
map({ "v", "x", "s" }, "D", '"_d', { noremap = true, desc = "Delete line without yanking", nowait = true })
map({ "n" }, "db", utils.DeleteBackward, { noremap = true, desc = "Удалить слово назад" })
map({ "n" }, "dd", "")
map({ "n" }, "dh", "")
map({ "n" }, "dl", "")
map({ "n" }, "dj", "")
map({ "n" }, "dk", "")

map({ "i" }, "<C-BS>", "<C-w>", { noremap = true, silent = true })
map({ "n" }, "<BS>", '"_cl<Esc>', { noremap = true, desc = "Удалить символ влево" })
map({ "n" }, "<delete>", '"_x', { noremap = true, desc = "Удалить символ влево" })

map({ "x", "n", "v" }, "c", '"_c', { noremap = true, desc = "Change without yanking", nowait = true })
map({ "x", "n", "v" }, "C", '"_VdO', { noremap = true, desc = "Change without yanking", nowait = true })
map({ "n" }, "Y", "Vy", { noremap = true })
map({ "n" }, "yy", "m`0y$``", { noremap = true })

--
-- Snacks
unmap("n", "<leader>e")
unmap("n", "<leader>E")
map("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Snacks (Root Dir)" })
map("n", "<leader>E", function()
  Snacks.picker.explorer()
end, { desc = "Snacks Picker Explorer" })
map("n", "<leader><space>", function()
  Snacks.picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "find files (cwd)" })
map("n", "<leader>sg", function()
  LazyVim.pick("live_grep", { root = false })()
end, { desc = "Grep (cwd)" })
map("n", "<leader>sG", function()
  LazyVim.pick("live_grep")()
end, { desc = "Grep (Root Dir)" })
map("n", "gR", function()
  vim.cmd('normal! "yyiw')
  Snacks.picker.grep({ search = vim.fn.getreg('"') })
end, { desc = "Grep Word Under Cursor (Snacks)" })

--
-- Buffers and tabs
map({ "n", "v", "i" }, ">", function()
  utils.BufferCycle(1)
end, { silent = true, desc = "Next buffer" })
map({ "n", "v", "i" }, "<", function()
  utils.BufferCycle(-1)
end, { silent = true, desc = "Previous buffer" })
map({ "n", "v", "i" }, "w", function()
  utils.BufferDelete()
end, { silent = true, desc = "Previous buffer" })
map({ "n" }, "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
map({ "n" }, "<leader>bmf", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer forward" })
map({ "n" }, "<leader>bmb", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer back" })
map(
  { "n" },
  "<leader>ba",
  "<cmd>bufdo if &buftype == '' | bd | endif<cr>",
  { silent = true, desc = "Close all buffers" }
)
map({ "n" }, "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map({ "n" }, "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
map({ "n" }, "<leader>tp", "<cmd>tabprev<CR>", { desc = "Previoues tab" })
map({ "n" }, "<leader><C-r>", "<cmd>e<cr>", { desc = "Reload buffer" })

--
-- GIT Comannds
map({ "v", "x" }, "<leader>go", "<Esc><cmd>'<,'>GBrowse<cr>", { noremap = true, desc = "Git Open Remote" })
map({ "n" }, "<leader>go", "<cmd>GBrowse<cr>", { noremap = true, silent = true, desc = "Git Open Remote" })
map("n", "<leader>gr", utils.OpenRepository, { desc = "Git Remote Root" })

--
-- Remap Lazy l -> lv
unmap({ "n" }, "<leader>l")
map({ "n" }, "<leader>lv", "<cmd>Lazy<CR>")

--
-- And others
map({ "i" }, "<A-d>", "<C-o>dw", { noremap = true, desc = "Remove word forward in insert mode" })
map({ "n" }, "<leader>lsr", "<cmd>LspRestart<cr>", { noremap = true, silent = true })
map({ "n" }, "<leader>lss", "<cmd>LspStop<cr>", { noremap = true, silent = true })
map({ "n", "v", "x" }, "$", "g_", { noremap = true, desc = "Go to the last character at the line" })
map({ "n", "v", "x" }, "g_", "$", { noremap = true, desc = "Go to the end of line" })
map({ "n" }, "<leader>rn", utils.SetTmuxWindowName, { desc = "Rename Tmux Window" })
map({ "n" }, "a", utils.SmartInsertOnEmptyLine, { noremap = true, expr = true, desc = "Auto indent" })
map({ "n", "v", "x" }, "<leader>rs", utils.ReplaceWithSubstituteCommand, { desc = "Replace with /s command" })
map({ "v" }, "<leader>ra", utils.ReplaceSelectionAcrossFile, { desc = "Substitute current selection" })
map({ "n" }, "<leader>op", utils.OpenFromClipboard, { desc = "Open file from clipboard" })
vim.on_key(utils.LanguageControl)

map({ "n", "v", "x" }, "<leader>m", function()
  require("mini.map").toggle()
end, { noremap = true, desc = "toggle minimap" })

map("n", "<leader>tf", function()
  vim.cmd("silent %!deno fmt --ext=md --options-line-width=2000 -")
end, { desc = "Deno Format Markdown", nowait = true })
map(
  "v",
  "<leader>tf",
  ":!deno fmt --ext=md --options-line-width=2000 -<cr>",
  { desc = "Deno Format Selection", nowait = true, silent = true }
)

Snacks.config.picker.actions = vim.tbl_deep_extend("force", Snacks.config.picker.actions or {}, {
  lazygit = function()
    local explorer = Snacks.picker.get({ source = "explorer" })[1]
    if explorer then
      explorer:close()
    end
    lazygit.ToggleLazygit()
  end,
})
map({ "n" }, "<leader>kn", function()
  require("kulala").scratchpad()
end, { desc = "Focus Kulala Scratchpad" })
map({ "n" }, "<leader>ko", function()
  require("kulala").open()
  vim.defer_fn(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>l", true, false, true), "n", true)
  end, 10)
end, { desc = "Focus Kulala Scratchpad" })
