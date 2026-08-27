local dap = require("dap")
local dapui = require("dapui")
local utils = require("config.utils.keymaps")
local lazygit = require("config.utils.lazygit")

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
map({ "n" }, "<", "<l", { noremap = true, silent = true, desc = "Indent line back" })
map({ "n" }, ">", ">l", { noremap = true, silent = true, desc = "Indent line" })
map("n", "<A-j>", function()
  local count = vim.v.count1
  vim.cmd("move .+" .. count)
end, { silent = true })

map("n", "<A-k>", function()
  local count = vim.v.count1
  vim.cmd("move .-" .. (count + 1))
end, { silent = true })
map({ "n", "v" }, "G", "G$", { noremap = true, silent = true, desc = "Go to the end of the file" })
map({ "n", "v" }, "gg", "gg^", { noremap = true, silent = true, desc = "Go to the start of the file" })
map({ "n", "v" }, "<C-y>", "<cmd>%y<CR>", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "<C-v>", "ggVG", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "<M-v>", "<C-v>", { noremap = true, silent = true, desc = "Yank whole file" })
map({ "n", "v" }, "m", "`", { noremap = true, silent = true, desc = "Go mark" })
map({ "n", "v" }, "mm", "m", { noremap = true, silent = true, desc = "Make mark" })
map("n", "dm", utils.DelMarks, { desc = "Удалить все метки на текущей строке" })
map("n", "yb", "vby", { noremap = true, silent = true, desc = "Yank backwards" })

map("n", "v", "<Esc>v", { noremap = true, silent = true })
map("n", "<C-d>", utils.SmartScroll("down"))
map("n", "<C-u>", utils.SmartScroll("up"))

--
-- Terminal
-- Привязываем к Ctrl + / и Ctrl + _ (для Windows)
unmap("n", "<C-/>")
map({ "n", "t", "i" }, "<C-t>", utils.ToggleTerminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<M-t>", utils.ToggleTmuxTerminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<C-_>", utils.ToggleTerminal, { desc = "Toggle Terminal" })
map({ "t" }, "<C-n>", [[<C-\><C-n>]], { desc = "Go normanl mode from terminal" })
-- map({ "t" }, "<C-u>", [[<C-\><C-n><C-u>]], { desc = "Go normanl mode from terminal" })
map({ "t" }, "<C-u>", function()
  local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
  vim.schedule(function()
    local target_height = math.floor(vim.o.lines * 0.6)
    vim.api.nvim_win_set_height(0, target_height)
  end)
end, { desc = "Go normal mode and resize terminal to 80%" })

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
  vim.cmd('normal! 0v$"_d')
  vim.cmd('normal! "' .. reg .. "P")
  LazyVim.format()
end, { silent = true, desc = "Paste in new line" })

map({ "n", "v" }, "<leader>P", function()
  local reg = vim.v.register
  vim.cmd("normal! O")
  vim.cmd('normal! 0v$"_d')
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
map("v", "gw(", utils.Wrap("(", ")"), { noremap = true, desc = "Wrap" })
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
map({ "n" }, "dj", function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("+1delete")
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end, { silent = true, desc = "Delete line below without moving cursor" })
map({ "n" }, "dk", function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("-1delete")
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end, { silent = true, desc = "Delete line below without moving cursor" })

map({ "i" }, "<C-BS>", "<C-w>", { noremap = true, silent = true })
map({ "n" }, "<BS>", '"_cl<Esc>', { noremap = true, desc = "Удалить символ влево" })
map({ "n" }, "<delete>", '"_x', { noremap = true, desc = "Удалить символ влево" })

map({ "x", "n", "v" }, "c", '"_c', { noremap = true, desc = "Change without yanking", nowait = true })
map({ "x", "n", "v" }, "C", 'V"_dO', { noremap = true, desc = "Change without yanking", nowait = true })
map({ "n" }, "Y", "Vy", { noremap = true })
map({ "n" }, "yy", "m`0y$``", { noremap = true })

--
-- Snacks
unmap("n", "<leader>e")
unmap("n", "<leader>E")

-- TODO: когда открыл не тот файл, закрыл его и кирдык, опять в эксплорере листать до него
map({ "n", "i", "t" }, "", function()
  Snacks.explorer({ diagnostics_open = false, cwd = utils.GetCWD() })
end, { desc = "Toggle Explorer" })
map({ "n", "t" }, "<leader>,", function()
  local picker = Snacks.picker.buffers({
    cwd = utils.GetCWD(),
  })
  picker:action("list_down")
end, { desc = "Toggle Explorer" })

-- map({ "n", "i", "t" }, "", function()
--   Snacks.picker.projects()
-- end, { desc = "Projects" })

map("n", "<leader>e", function()
  local session_file = vim.v.this_session
  if session_file == "" then
    return
  end
  local save_ignore = vim.opt.eventignore:get()
  vim.opt.eventignore:append("all")
  local session_dir = vim.fn.fnamemodify(session_file, ":p:h") .. "/"
  pcall(vim.api.nvim_set_current_dir, session_dir)
  vim.opt.eventignore = save_ignore

  Snacks.picker.explorer()
end, { desc = "Snacks Picker Explorer" })
map("n", "<leader><space>", function()
  Snacks.picker.files({ cwd = utils.GetCWD() })
end, { desc = "find files (cwd)" })
map("n", "<leader>sg", function()
  Snacks.picker.grep({ cwd = utils.GetCWD() })
end, { desc = "Grep (cwd)" })
map("n", "<leader>sG", function()
  LazyVim.pick("live_grep")()
end, { desc = "Grep (Root Dir)" })

--
-- Buffers and tabs
map({ "n", "v", "i" }, ">", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" or mode == "t" then
    vim.cmd("silent! stopinsert")
  end
  vim.cmd("tabnext")
end, { silent = true, desc = "Next buffer" })
map({ "n", "v", "i" }, "<", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" or mode == "t" then
    vim.cmd("silent! stopinsert")
  end
  vim.cmd("tabprev")
end, { silent = true, desc = "Previous buffer" })
-- map({ "n" }, "<leader>bmf", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer forward" })
-- map({ "n" }, "<leader>bmb", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer back" })
map({ "n", "v", "i" }, "w", function()
  utils.BufferDelete()
end, { silent = true, desc = "Delete buffer" })
map({ "n" }, "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
map(
  { "n" },
  "<leader>ba",
  "<cmd>bufdo if &buftype == '' || &buftype == 'acwrite' | bd | endif<cr>",
  { silent = true, desc = "Close all buffers" }
)
map({ "n" }, "<leader>td", "<cmd>tabclose<CR>", { desc = "Close tab" })
-- map({ "n" }, "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
-- map({ "n" }, "<leader>tp", "<cmd>tabprev<CR>", { desc = "Previoues tab" })
map({ "n" }, "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map({ "n" }, "<leader>rf", "<cmd>e<cr>", { desc = "Reload buffer" })
map({ "n" }, "<leader>ts", function()
  require("config.utils.tabs_picker").tabs_picker()
end, { desc = "Snacks: Tabs Picker" })

--
-- GIT Comannds
map({ "v", "x" }, "<leader>go", "<Esc><cmd>'<,'>GBrowse<cr>", { noremap = true, desc = "Git Open Remote" })
map({ "n" }, "<leader>go", "<cmd>GBrowse<cr>", { noremap = true, silent = true, desc = "Git Open Remote" })
unmap({ "n" }, "<leader>gf")
map({ "n" }, "<leader>gfl", function()
  require("snacks").picker.git_log_file({
    layout = {
      layout = {
        box = "horizontal",
        fulscreen = true,
        {
          box = "vertical",
          border = "rounded",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", border = "none" },
          { win = "preview", height = 0.80, border = "top" },
        },
      },
    },
  })
end, { noremap = true, silent = true, desc = "Git Open File History" })
map({ "n" }, "<leader>gfs", function()
  vim.fn.system({ "git", "add", vim.api.nvim_buf_get_name(0) })
end, { noremap = true, silent = true, desc = "Git Stage File" })
map("n", "<leader>gr", utils.OpenRepository, { desc = "Git Remote Root" })

--
-- Remap LazyVim
unmap({ "n" }, "<leader>l")
map({ "n" }, "<leader>ll", "<cmd>Lazy<CR>")
map({ "n" }, "<leader>lx", "<cmd>LazyExtras<CR>")
map({ "n" }, "<leader>vq", "<cmd>qa<CR>")

--
-- And others
map({ "i" }, "<A-d>", "<C-o>dw", { noremap = true, desc = "Remove word forward in insert mode" })
map({ "n" }, "<leader>lsr", "<cmd>LspRestart<cr>", { noremap = true, silent = true })
map({ "n" }, "<leader>lss", "<cmd>LspStop<cr>", { noremap = true, silent = true })
-- map({ "n", "v", "x" }, "$", "g_", { noremap = true, desc = "Go to the last character at the line" })
-- map({ "n", "v", "x" }, "g_", "$", { noremap = true, desc = "Go to the end of line" })
map({ "n" }, "<leader>rn", utils.SetTmuxWindowName, { desc = "Rename Tmux Window" })
map({ "n" }, "a", utils.SmartInsertOnEmptyLine, { noremap = true, expr = true, desc = "Auto indent" })
map({ "n", "v", "x" }, "<leader>rs", utils.ReplaceWithSubstituteCommand, { desc = "Replace with /s command" })
map({ "v" }, "<leader>ra", utils.ReplaceSelectionAcrossFile, { desc = "Substitute current selection" })
map({ "n" }, "<leader>op", utils.OpenFromClipboard, { desc = "Open file from clipboard" })
map({ "n" }, "ш", "i")
map({ "n" }, "ф", "a")
map({ "n" }, "Ш", "I")
map({ "n" }, "Ф", "A")
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
map({ "n" }, "<leader>ks", function()
  require("kulala").set_selected_env()
end, { desc = "Select Enviroment" })
