local dap = require("dap")
local bufferline = require("bufferline")

local M = {}

function M.DapToggleDebug()
  if dap.session() ~= nil then
    dap.terminate()
    return
  end
  vim.cmd(":DapNew")
end

function M.DeleteBackward()
  local col = vim.fn.col(".")
  local line = vim.fn.getline(".")
  local last_col = #line
  local success, err = pcall(function()
    if col >= last_col - 1 then
      vim.cmd('normal! vb"_d')
      return
    end
    vim.cmd('normal! vb"_dh')
  end)

  if not success then
    vim.notify("Невозможно внести изменения в буфер.\n" .. err, vim.log.levels.WARN)
  end
end

function M.CutBackward()
  local col = vim.fn.col(".")
  local last_col = vim.fn.col("$")

  if col >= last_col - 1 then
    vim.cmd("normal! vbd")
    return
  end
  vim.cmd("normal! vbdh")
end

function M.SmartInsertOnEmptyLine()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*$") then
    return [["_cc]]
  else
    return "a"
  end
end

function M.GetShortName()
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
  local name = vim.g.tmux_window_name or M.GetShortName()
  vim.fn.jobstart({ "tmux", "rename-window", name })
end

function M.SetTmuxWindowName()
  local new_name = vim.fn.input("Имя окна tmux: ", vim.g.tmux_window_name or "")
  if new_name ~= "" then
    vim.g.tmux_window_name = new_name
    update_tmux_window()
  end
end

local status, hl_normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal" })
local fixed_bg = (status and hl_normal.bg) or "NONE"

function M.LanguageControl(key)
  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" or mode == "R" then
    return
  end

  if key:match("[%z\1-\127]") == nil and key:match("[а-яА-ЯёЁ]") then
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

    -- Красим (используем константу вместо динамического определения)
    vim.api.nvim_set_hl(0, "Normal", { bg = "#5f0000" })

    vim.defer_fn(function()
      -- Всегда возвращаем к заранее запомненному fixed_bg
      vim.api.nvim_set_hl(0, "Normal", { bg = fixed_bg })
    end, 50)
  end
end

function M.ReplaceSelectionAcrossFile()
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
end

function M.ReplaceWithSubstituteCommand()
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "n" and mode ~= "v" and mode ~= "V" and mode ~= "" then
    return
  end

  if mode == "n" then
    local command = ":%s/\\v"
    vim.api.nvim_feedkeys(command, "n", false)
    return
  end

  local command = ":s/\\v"
  vim.api.nvim_feedkeys(command, "n", false)
end

-- Центрирование при прокрутке на пол-экрана вверх/вниз
function M.SmartScroll(direction)
  return function()
    local winline = vim.fn.winline()
    local winheight = vim.api.nvim_win_get_height(0)
    local middle = math.floor(winheight / 2)

    -- if (winline - middle > 1 and direction == "up") or (winline - middle < -1 and direction == "down") then
    --   local move = middle - winline
    --   local letter = "k"
    --   if direction == "down" then
    --     letter = "j"
    --   end
    --   vim.cmd(string.format("normal! %d%s", move, letter))
    --   return
    -- end

    local lines = math.floor(winheight / 2)
    if direction == "down" then
      require("neoscroll").scroll(lines, {
        move_cursor = false,
        duration = 150, -- время в мс
        easing = "linear", -- тип анимации
      })
    else
      require("neoscroll").scroll(-lines, {
        move_cursor = false,
        duration = 150,
        easing = "linear",
      })
    end

    -- vim.schedule(function()
    --   vim.cmd("normal! zz")
    -- end)
  end
end

local function get_snacks_terminal_wins()
  local terminal_wins = {}
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if vim.b[bufnr].snacks_terminal then
      table.insert(terminal_wins, winid)
    end
  end
  return terminal_wins
end

local function has_value(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function M.ToggleTerminal()
  local winids = get_snacks_terminal_wins()
  if #winids > 0 and not has_value(winids, vim.api.nvim_get_current_win()) then
    vim.api.nvim_set_current_win(winids[1])
    return
  end
  if #winids > 0 and has_value(winids, vim.api.nvim_get_current_win()) then
    vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
    return
  end

  Snacks.terminal.toggle(nil, {
    cwd = vim.fn.getcwd(),
  })
end

local os = require("os")
function M.ToggleTmuxTerminal()
  local cwd = vim.fn.getcwd()
  os.execute("tmux split-window -v -c " .. cwd)
end

function M.OpenRepository()
  local url = vim.fn.system("git remote get-url origin"):gsub("\n", "")

  url = url:gsub("git@(.+):", "https://%1/")
  url = url:gsub("%.git$", "")

  if vim.ui.open then
    vim.ui.open(url)
  else
    vim.fn.jobstart({ "open", url })
  end
end

function M.Wrap(key1, key2)
  return function()
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= "v" and mode ~= "V" then
      return
    end

    vim.cmd('normal! "yd')
    if mode == "v" then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("i" .. key1 .. key2 .. '<Esc>"yP', true, false, true),
        "n",
        false
      )
      return
    end

    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("O<Esc>i" .. key1 .. key2 .. "<Esc>i<CR><Esc>kp", true, false, true),
      "n",
      false
    )
  end
end

function M.OpenFromClipboard()
  local path = vim.fn.system("xclip -o -selection clipboard"):gsub("%s+", "")
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("e " .. path)
  else
    print("Файл не найден: " .. path)
  end
end

function M.BufferCycle(num)
  local prev_buf = vim.api.nvim_get_current_buf()

  local is_empty_and_nameless = false
  if
    vim.api.nvim_buf_is_valid(prev_buf)
    and vim.api.nvim_buf_get_name(prev_buf) == ""
    and vim.bo[prev_buf].buftype == ""
    and not vim.bo[prev_buf].modified
  then
    local lines = vim.api.nvim_buf_get_lines(prev_buf, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      is_empty_and_nameless = true
    end
  end

  bufferline.cycle(num)

  if is_empty_and_nameless then
    pcall(vim.api.nvim_buf_delete, prev_buf, { force = true })
  end

  local mode = vim.api.nvim_get_mode().mode
  if mode == "i" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

function M.BufferDelete()
  local bufnr = vim.api.nvim_get_current_buf()
  local is_terminal = vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal"

  if is_terminal and vim.api.nvim_get_mode().mode == "nt" then
    vim.api.nvim_buf_delete(bufnr, { force = true })
    return
  end

  local listed = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())

  if #listed == 0 then
    return
  end

  local function force_delete()
    if vim.api.nvim_get_mode().mode == "i" then
      vim.cmd("stopinsert")
    end

    if #listed == 1 and listed[1] == vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(bufnr, { force = true })
      vim.cmd("enew")
      return
    end

    local origin = bufnr

    if vim.api.nvim_buf_is_valid(origin) then
      vim.api.nvim_buf_delete(origin, { force = true })
    end
  end

  if vim.bo[bufnr].modified then
    local choice = vim.fn.confirm("File is modified! Save?", "&Yes\n&No\n&Cancel", 1)

    if choice == 1 then
      vim.cmd("write")
      force_delete()
    elseif choice == 2 then
      vim.cmd("setlocal nomodified")
      force_delete()
    end

    return
  end

  force_delete()
end

function M.DelMarks()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_buf = vim.api.nvim_get_current_buf()
  local marks_to_delete = {}
  for _, mark_data in ipairs(vim.fn.getmarklist(current_buf)) do
    local name = mark_data.mark:sub(2)
    if mark_data.pos[2] == current_line and name:match("%l") then
      table.insert(marks_to_delete, name)
    end
  end
  for _, mark_data in ipairs(vim.fn.getmarklist()) do
    local name = mark_data.mark:sub(2)
    if mark_data.pos[1] == current_buf and mark_data.pos[2] == current_line and name:match("%u") then
      table.insert(marks_to_delete, name)
    end
  end
  if #marks_to_delete > 0 then
    local marks_str = table.concat(marks_to_delete, " ")
    vim.cmd("delmarks " .. marks_str)
  else
    print("На текущей строке нет меток")
  end
end

return M
