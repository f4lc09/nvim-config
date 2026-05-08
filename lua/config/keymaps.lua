local dap = require("dap")
local bufferline = require("bufferline")
local dapui = require("dapui")
local utils = require("config.keymap_utils")

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
-- Центрирование при прокрутке на пол-экрана вверх/вниз
local function smart_scroll(direction)
  return function()
    local winline = vim.fn.winline()
    local winheight = vim.api.nvim_win_get_height(0)
    local middle = math.floor(winheight / 2)

    if (winline - middle > 1 and direction == "up") or (winline - middle < -1 and direction == "down") then
      local move = middle - winline
      local letter = "k"
      if direction == "down" then
        letter = "j"
      end
      vim.cmd(string.format("normal! %d%s", move, letter))
      return
    end

    local lines = math.floor(winheight / 2)
    if direction == "down" then
      require("neoscroll").scroll(lines, {
        move_cursor = true,
        duration = 150, -- время в мс
        easing = "linear", -- тип анимации
      })
    else
      require("neoscroll").scroll(-lines, {
        move_cursor = true,
        duration = 150,
        easing = "linear",
      })
    end

    vim.schedule(function()
      vim.cmd("normal! zz")
    end)
  end
end
vim.keymap.set("n", "<C-d>", smart_scroll("down"))
vim.keymap.set("n", "<C-u>", smart_scroll("up"))

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
-- Buffer cycling
map({ "n", "v" }, "<leader>bf", function()
  bufferline.cycle(1)
end, { silent = true, desc = "Next buffer" })
map({ "n", "v" }, "<leader>bb", function()
  bufferline.cycle(-1)
end, { silent = true, desc = "Previous buffer" })
map({ "n" }, "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })

--
-- Lazygit Toggling
local Terminal = require("toggleterm.terminal").Terminal
local lazygit
function ToggleLazygit()
  local cwd = vim.fn.getcwd()
  if lazygit and not string.find(cwd, lazygit.dir, 1, true) then
    lazygit:shutdown()
    lazygit = nil
  end
  if not lazygit then
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
      -- stylua: ignore
      on_open = function(term)
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "t", "<C-g>",
          [[<C-\><C-n><cmd>lua ToggleLazygit()<CR>]], { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "n", "<C-g>",
          [[<cmd>lua ToggleLazygit()<CR>]], { noremap = true, silent = true })
      end,
    })
  end
  lazygit:toggle()
  vim.defer_fn(function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert!")
    end
  end, 50)
end
map("n", "<C-g>", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  ToggleLazygit()
end, { noremap = true, silent = true })

--
-- Remap Lazy l -> lv
unmap({ "n" }, "<leader>l")
map({ "n" }, "<leader>lv", "<cmd>Lazy<CR>")

--
-- And others
map("t", "<C-c><C-c>", [[<C-\><C-n>:bd!<CR>]], { desc = "Убить терминал" })
map("i", "<A-d>", "<C-o>dw", { noremap = true })
map({ "v", "x" }, "$", "g_", { noremap = true })

map("n", "<leader>rn", utils.SetTmuxWindowName, { desc = "Rename Tmux Window" })
map("n", "a", utils.SmartInsertOnEmptyLine, { noremap = true, expr = true, desc = "Auto indent" })
vim.on_key(utils.LanguageControl)

unmap("n", "<leader>e")
unmap("n", "<leader>E")
unmap("n", "<C-/>")

map("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Snacks (Root Dir)" })
map("n", "<leader>E", function()
  Snacks.picker.explorer()
end, { desc = "Snacks Picker Explorer" })

-- map("n", "<C-_>", function()
--   Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
-- end, { desc = "Terminal" })
local toggle_terminal = function()
  Snacks.terminal.toggle(nil, {
    cwd = vim.fn.getcwd(),
  })
end
local os = require("os")
local toggle_tmux_terminal = function()
  local cwd = vim.fn.getcwd()
  os.execute("tmux split-window -v -c " .. cwd)
end

-- Привязываем к Ctrl + / и Ctrl + _ (для Windows)
-- Режимы: n (обычный), t (внутри терминала), i (вставка)
map({ "n", "t", "i" }, "<C-/>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<C-\\>", toggle_tmux_terminal, { desc = "Toggle Terminal" })
map({ "n", "t", "i" }, "<C-_>", toggle_terminal, { desc = "Toggle Terminal" })

map(
  { "v", "x" },
  "<leader>go",
  "<Esc><cmd>'<,'>GBrowse<cr>",
  { noremap = true, silent = true, desc = "Git Open Remote" }
)
map({ "n" }, "<leader>go", "<cmd>GBrowse<cr>", { noremap = true, silent = true, desc = "Git Open Remote" })
vim.keymap.set("n", "<leader>gr", function()
  local url = vim.fn.system("git remote get-url origin"):gsub("\n", "")

  url = url:gsub("git@(.+):", "https://%1/")
  url = url:gsub("%.git$", "")

  if vim.ui.open then
    vim.ui.open(url)
  else
    vim.fn.jobstart({ "open", url })
  end
end, { desc = "Git Remote Root (Pure URL)" })
map("n", "<leader>lsr", "<cmd>LspRestart<cr>", { noremap = true, silent = true })
map("n", "<leader>lss", "<cmd>LspStop<cr>", { noremap = true, silent = true })

map({ "n", "v", "x" }, "<leader>rs", utils.ReplaceWithSubstituteCommand, { desc = "Replace with /s command" })
map("v", "<leader>ra", utils.ReplaceSelectionAcrossFile, { desc = "Substitute current selection" })
map({ "n", "v", "x" }, "<leader>mp", function()
  require("mini.map").toggle()
end, { noremap = true, desc = "toggle minimap" })
map("n", "<leader>sg", function()
  LazyVim.pick("live_grep", { root = false })()
end, { desc = "Grep (cwd)" })
map("n", "<leader>sG", function()
  LazyVim.pick("live_grep")()
end, { desc = "Grep (Root Dir)" })
map("n", "<leader>tf", function()
  vim.cmd("silent %!deno fmt --ext=md --options-line-width=2000 -")
end, { desc = "Deno Format Markdown", nowait = true })
map(
  "v",
  "<leader>tf",
  ":!deno fmt --ext=md --options-line-width=2000 -<cr>",
  { desc = "Deno Format Selection", nowait = true, silent = true }
)
map("n", "<leader>op", function()
  local path = vim.fn.system("xclip -o -selection clipboard"):gsub("%s+", "")
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("e " .. path)
  else
    print("Файл не найден: " .. path)
  end
end, { desc = "Open file from clipboard" })
map("n", "<leader>bmf", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer forward" })
map("n", "<leader>bmb", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer back" })
map("n", "<leader>ba", "<cmd>%bd<CR>", { desc = "Close all buffers" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabprev<CR>", { desc = "Previoues tab" })
map("t", "<C-n>", [[<C-\><C-n>]])
map("n", "<C-r>", "<cmd>e<cr>")
