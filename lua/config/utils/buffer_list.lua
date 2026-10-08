local M = {}

local float_buf = nil
local float_win = nil

local hidden_by_cursor = false

local ns_id = vim.api.nvim_create_namespace("BufferListHighlight")

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

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
      local icon = "📄"
      local icon_hl = nil

      if full_name ~= "" then
        name = vim.fs.basename(full_name)
        ext = vim.fn.fnamemodify(name, ":e")

        if has_devicons then
          local i, hl = devicons.get_icon(name, ext, { default = true })
          icon = i or icon
          icon_hl = hl
        end
      end

      local is_current = (buf == current_buf)
      local prefix = "   "
      local prefix_hl
      if is_current then
        prefix = " * "
        prefix_hl = "ModeMsg"
      end
      if vim.bo[buf].modified then
        prefix = " ● "
        prefix_hl = "Macro"
      end
      if vim.bo[buf].modified and is_current then
        prefix = "*● "
        prefix_hl = "Macro"
      end

      local line_text = prefix .. icon .. " " .. name
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
        prefix_hl = prefix_hl,
      })
    end
  end
  return lines, max_width + 1
end

local function is_cursor_over_win(opts)
  local cursor_row = vim.fn.screenrow()
  local cursor_col = vim.fn.screencol()
  local top = opts.row
  local bottom = opts.row + opts.height + 2
  local left = opts.col
  local right = opts.col + opts.width + 2
  return cursor_row >= top and cursor_row <= bottom and cursor_col >= left and cursor_col <= right
end

function M.update_window()
  vim.api.nvim_set_hl(0, "BufferListNormal", { bg = "none", blend = 0 })
  vim.api.nvim_set_hl(0, "BufferListBorder", { bg = "none", fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "BufferListCurrent", { link = "CursorLine", bold = true })

  local buffer_info, max_width = get_buffer_lines()

  if #buffer_info == 0 then
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
    float_win = nil
    float_buf = nil
    hidden_by_cursor = false
    return
  end

  local lines = {}
  for _, info in ipairs(buffer_info) do
    local current_width = vim.fn.strdisplaywidth(info.text)
    local padding = string.rep(" ", max_width - current_width)
    table.insert(lines, info.text .. padding)
  end

  local height = #lines

  local opts = {
    relative = "editor",
    width = max_width,
    height = height,
    row = 9,
    col = vim.o.columns - max_width - 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 150,
  }

  if is_cursor_over_win(opts) then
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
      float_win = nil
    end
    hidden_by_cursor = true
    return
  end
  hidden_by_cursor = false

  if float_win and vim.api.nvim_win_is_valid(float_win) then
    local win_tab = vim.api.nvim_win_get_tabpage(float_win)
    local current_tab = vim.api.nvim_get_current_tabpage()
    if win_tab ~= current_tab then
      vim.api.nvim_win_close(float_win, true)
      float_win = nil
    end
  end

  if not (float_win and vim.api.nvim_win_is_valid(float_win)) then
    if not float_buf or not vim.api.nvim_buf_is_valid(float_buf) then
      float_buf = vim.api.nvim_create_buf(false, true)
    end
    float_win = vim.api.nvim_open_win(float_buf, false, opts)
    vim.api.nvim_set_option_value("winhl", "Normal:BufferListNormal,FloatBorder:BufferListBorder", { win = float_win })
  else
    vim.api.nvim_win_set_config(float_win, opts)
  end

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(float_buf, ns_id, 0, -1)

  for idx, info in ipairs(buffer_info) do
    local line_idx = idx - 1
    if info.is_current then
      vim.api.nvim_buf_add_highlight(float_buf, ns_id, "BufferListCurrent", line_idx, 0, -1)
    end
    if info.icon_hl then
      vim.api.nvim_buf_add_highlight(float_buf, ns_id, info.icon_hl, line_idx, info.icon_start, info.icon_end)
    end
    if info.prefix_hl then
      vim.api.nvim_buf_add_highlight(float_buf, ns_id, info.prefix_hl, line_idx, 0, 3)
    end
  end
end

-- Переключатель для горячей клавиши
function M.toggle_buffer_list()
  if (float_win and vim.api.nvim_win_is_valid(float_win)) or hidden_by_cursor then
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
    float_win = nil
    float_buf = nil
    hidden_by_cursor = false
  else
    M.update_window()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ToggleBufferList", M.toggle_buffer_list, {})

  local group = vim.api.nvim_create_augroup("BufferListAutoUpdate", { clear = true })

  -- Добавлены события TabEnter и TabNew для отслеживания смены вкладок
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufDelete", "VimResized", "WinEnter", "CursorMoved", "TabEnter", "TabNew", "BufWrite" },
    {
      group = group,
      callback = function()
        vim.schedule(function()
          M.update_window()
        end)
      end,
    }
  )

  M.update_window()
end

return M
