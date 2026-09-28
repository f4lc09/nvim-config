local M = {}

local float_buf = nil
local float_win = nil

-- Функция получения списка имен открытых буферов
local function get_buffer_lines()
  local lines = {}
  local bufs = vim.api.nvim_list_bufs()
  local max_width = 0

  local visible_bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible_bufs[vim.api.nvim_win_get_buf(win)] = true
  end

  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then
        name = "[No Name]"
        if max_width < #name + 2 then
          max_width = #name + 3
        end
      else
        name = vim.fs.basename(name)
        if max_width < #name + 2 then
          max_width = #name + 3
        end
      end

      local status = "  "
      if buf == vim.api.nvim_get_current_buf() then
        status = "● "
      elseif not visible_bufs[buf] then
        status = "  " -- Выводим флаг 'h' для скрытых буферов
      end

      table.insert(lines, status .. name)
    end
  end
  return lines, max_width
end

-- Единая функция для умного создания и обновления окна
function M.update_window()
  vim.api.nvim_set_hl(0, "BufferListNormal", { bg = "none", blend = 0 })
  vim.api.nvim_set_hl(0, "BufferListBorder", { bg = "none", fg = "#7aa2f7" })

  local lines, max_width = get_buffer_lines()
  if #lines == 0 then
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
    float_win = nil
    float_buf = nil
    return
  end
  local height = #lines

  -- Динамический расчет координат для ПРАВОГО НИЖНЕГО угла
  local opts = {
    relative = "editor",
    width = max_width,
    height = height,
    row = vim.o.lines - height - 3, -- Отступ снизу с учетом статус-строки
    col = vim.o.columns - max_width - 2, -- Отступ справа
    style = "minimal",
    border = "rounded",
    focusable = false,
  }

  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    vim.api.nvim_win_set_config(float_win, opts)
  else
    float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    float_win = vim.api.nvim_open_win(float_buf, false, opts)
    vim.api.nvim_set_option_value("winhl", "Normal:BufferListNormal,FloatBorder:BufferListBorder", { win = float_win })
  end
end

-- Переключатель для горячей клавиши (показать/скрыть вручную)
function M.toggle_buffer_list()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    float_buf = nil
  else
    M.update_window()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ToggleBufferList", M.toggle_buffer_list, {})

  local group = vim.api.nvim_create_augroup("BufferListAutoUpdate", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete", "VimResized", "WinEnter" }, {
    group = group,
    callback = function()
      -- vim.schedule гарантирует выполнение кода после того, как Neovim применит состояние буферов
      vim.schedule(function()
        M.update_window()
      end)
    end,
  })

  -- Запускаем отрисовку сразу при вызове setup
  M.update_window()
end

return M
