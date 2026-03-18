local dap = require("dap")
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
  local last_col = vim.fn.col("$")

  if col >= last_col - 1 then
    vim.cmd('normal! vb"_d')
    return
  end
  vim.cmd('normal! vb"_dh')
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

function M.SetupKulalaKeymaps(bufnr)
  local map = vim.keymap.set
  map("n", "<Enter>", function()
    local success, kulala_module = pcall(require, "kulala")
    if success and kulala_module then
      kulala_module.run()
    end
  end, {
    desc = "Run HTTP request",
    buffer = bufnr,
  })
end

function M.SetupGoTestKeymaps(bufnr)
  local map = vim.keymap.set
  local filename = vim.fn.bufname(bufnr)
  if filename:match("_test.go$") then
    map("n", "<F5>", function()
      local success, dap_go_module = pcall(require, "dap-go")
      if success and dap_go_module then
        dap_go_module.debug_test()
      end
    end, {
      desc = "Debug nearest Go test",
      buffer = bufnr,
    })
  end
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
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

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
  vim.cmd('normal! "hy')
  local command = ":%s/"
  vim.api.nvim_feedkeys(command, "n", false)
end

return M
