local M = {}

local float_buf = nil
local float_win = nil
-- Создаем namespace для нашей кастомной подсветки
local ns_id = vim.api.nvim_create_namespace("BufferListHighlight")

-- Пытаемся безопасно подключить nvim-web-devicons
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

-- Функция получения списка имен открытых буферов и информации о них
local function get_buffer_lines()
  local lines = {}
  local bufs = vim.api.nvim_list_bufs()
  local max_width = 0
  local current_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local full_name = vim.api.nvim_buf_get_name(buf)
      local name = "[No Name]"
      local ext = ""
      local icon = "📄" -- Дефолтная иконка, если nvim-web-devicons не установлен
      local icon_hl = nil

      if full_name ~= "" then
        name = vim.fs.basename(full_name)
        ext = vim.fn.fnamemodify(name, ":e")

        -- Получаем иконку, если плагин доступен
        if has_devicons then
          local i, hl = devicons.get_icon(name, ext, { default = true })
          icon = i or icon
          icon_hl = hl
        end
      end

      local is_current = (buf == current_buf)
      -- local prefix = is_current and "● " or "  "
      local prefix = ""

      -- Формируем строку
      local line_text = prefix .. icon .. " " .. name

      -- Расчет ширины с учетом отображения символов на экране
      local width = vim.fn.strdisplaywidth(line_text)
      if max_width < width then
        max_width = width
      end

      table.insert(lines, {
        text = line_text,
        is_current = is_current,
        icon_start = #prefix,
        icon_end = #prefix + #icon,
        icon_hl = icon_hl,
      })
    end
  end
  return lines, max_width + 4 -- Добавили чуть больше отступа справа, чтобы фон не обрывался вплотную к тексту
end

-- Единая функция для умного создания и обновления окна
function M.update_window()
  -- Настройки базовой подсветки окна
  vim.api.nvim_set_hl(0, "BufferListNormal", { bg = "none", blend = 0 })
  vim.api.nvim_set_hl(0, "BufferListBorder", { bg = "none", fg = "#7aa2f7" })

  -- Наследуем фоновое выделение от текущей строки темы (CursorLine) и добавляем жирный шрифт
  vim.api.nvim_set_hl(0, "BufferListCurrent", { link = "CursorLine", bold = true })

  local buffer_info, max_width = get_buffer_lines()

  if #buffer_info == 0 then
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
    float_win = nil
    float_buf = nil
    return
  end

  -- Заполняем массив строк текстом
  local lines = {}
  for _, info in ipairs(buffer_info) do
    -- Добиваем строки пробелами до max_width, чтобы фоновое выделение было ровным на всю ширину окна
    local current_width = vim.fn.strdisplaywidth(info.text)
    local padding = string.rep(" ", max_width - current_width)
    table.insert(lines, info.text .. padding)
  end

  local height = #lines

  -- Настройки плавающего окна (правый нижний угол)
  local opts = {
    relative = "editor",
    width = max_width,
    height = height,
    row = vim.o.lines - height - 3,
    col = vim.o.columns - max_width - 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
  }

  if not (float_win and vim.api.nvim_win_is_valid(float_win)) then
    float_buf = vim.api.nvim_create_buf(false, true)
    float_win = vim.api.nvim_open_win(float_buf, false, opts)
    vim.api.nvim_set_option_value("winhl", "Normal:BufferListNormal,FloatBorder:BufferListBorder", { win = float_win })
  else
    vim.api.nvim_win_set_config(float_win, opts)
  end

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(float_buf, ns_id, 0, -1)

  for idx, info in ipairs(buffer_info) do
    local line_idx = idx - 1

    -- 1. Сначала применяем выделение строки для текущего буфера (весь ряд от 0 до -1)
    if info.is_current then
      vim.api.nvim_buf_add_highlight(float_buf, ns_id, "BufferListCurrent", line_idx, 0, -1)
    end

    -- 2. Поверх накладываем цвет иконки, чтобы фоновое выделение не сбивало её родной цвет
    if info.icon_hl then
      vim.api.nvim_buf_add_highlight(float_buf, ns_id, info.icon_hl, line_idx, info.icon_start, info.icon_end)
    end
  end
end

-- Переключатель для горячей клавиши
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
      vim.schedule(function()
        M.update_window()
      end)
    end,
  })

  M.update_window()
end

return M
