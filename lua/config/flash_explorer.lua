local M = {}

local flash_picker
local close_timer

function M.ShowFlashExplorer(file)
  if file == "" then
    return
  end

  if flash_picker and not flash_picker.closed then
    flash_picker:close()
  end

  if close_timer then
    close_timer:stop()
    close_timer:close()
    close_timer = nil
  end

  local cwd = vim.fn.getcwd()
  if not vim.startswith(file, cwd .. "/") and file ~= cwd then
    cwd = vim.fn.fnamemodify(file, ":h")
  end
  local explorer_source = require("snacks.picker.source.explorer")
  flash_picker = Snacks.picker({
    source = "flash_explorer",
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
        height = 0.9,
        col = -1,
        row = 0,
        border = "none",
        backdrop = false,
        box = "vertical",
        {
          win = "list",
          border = "none",
        },
      },
    },
  })

  close_timer = vim.uv.new_timer()
  close_timer:start(
    2000,
    0,
    vim.schedule_wrap(function()
      if flash_picker and not flash_picker.closed then
        flash_picker:close()
      end

      if close_timer == nil then
        return
      end
      close_timer:stop()
      close_timer:close()
      close_timer = nil
    end)
  )
  vim.on_key(function()
    if flash_picker and not flash_picker.closed then
      flash_picker:close()

      if close_timer then
        close_timer:stop()
        close_timer:close()
        close_timer = nil
      end
    end
  end)
end

return M
