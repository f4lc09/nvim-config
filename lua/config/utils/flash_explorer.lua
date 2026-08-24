local M = {}

local flash_picker
local close_timer

local inserts = { "a", "A", "i", "I", "o", "O" }

local ignore_combo = {
  { "m", "'", "z", "z", "z", "v", unpack(inserts) },
}

local function has_value(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function M.ShowFlashExplorer(file)
  if file == "" then
    return
  end

  if flash_picker and not flash_picker.closed then
    flash_picker:close()
    flash_picker = nil
  end

  if close_timer then
    close_timer:stop()
    close_timer:close()
    close_timer = nil
  end

  local cwd = vim.fn.getcwd()
  if not vim.startswith(file, cwd .. "/") and file ~= cwd then
    cwd = vim.fn.fnamemodify(file, ":h")
    -- туду: раскрывать cwd если мало включений
  end
  local explorer_source = require("snacks.picker.source.explorer")
  flash_picker = Snacks.picker({
    source = "flash_explorer",
    -- туду:
    -- sort = function ()
    -- end
    formatters = {
      file = { filename_only = true },
      severity = { icons = false },
    },
    finder = explorer_source.explorer,
    cwd = cwd,
    follow_file = true,
    enter = false,
    preview = false,
    layout = {
      preview = false,
      layout = {
        position = "float",
        relative = "editor",
        width = 35,
        height = 0.8,
        col = -1,
        row = 2,
        border = "none",
        backdrop = false,
        box = "vertical",
        {
          win = "list",
          border = "rounded",
        },
      },
    },
  })
  vim.schedule(function()
    if not flash_picker then
      return
    end
    flash_picker:action("explorer_close_all")
  end)

  close_timer = vim.uv.new_timer()
  close_timer:start(
    3000,
    0,
    vim.schedule_wrap(function()
      if flash_picker and not flash_picker.closed then
        flash_picker:close()
        flash_picker = nil
      end

      if close_timer == nil then
        return
      end
      close_timer:stop()
      close_timer:close()
      close_timer = nil
    end)
  )

  vim.on_key(function(key)
    -- TODO: проверять последовательность
    if has_value(ignore_combo[1], key) then
      return
    end

    if flash_picker and not flash_picker.closed then
      flash_picker:close()
      flash_picker = nil

      if close_timer then
        close_timer:stop()
        close_timer:close()
        close_timer = nil
      end
    end
  end)
end

function M.ShowFlashBuffers(file)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "hello",
    "world",
    "some information",
  })

  local width = 35
  local height = 10

  local ns = vim.api.nvim_create_namespace("my_float")
  vim.api.nvim_set_hl(ns, "NormalFloat", {
    link = "Normal",
  })
  vim.api.nvim_set_hl(ns, "FloatBorder", {
    fg = "#56B6C2",
    bg = "NONE",
  })
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 1,
    row = 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
  })

  vim.api.nvim_win_set_hl_ns(win, ns)
  vim.api.nvim_set_option_value("winblend", 0, { win = win })
end

for _, v in ipairs(inserts) do
  vim.keymap.set("n", v, function()
    if flash_picker and not flash_picker.closed then
      flash_picker:close()
      flash_picker = nil
    end
    vim.schedule(function()
      vim.api.nvim_feedkeys(v, "n", false)
    end)
  end)
end

return M
