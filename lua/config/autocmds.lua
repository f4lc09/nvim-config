local utils = require("config.utils.autocmds")
local keymap_utils = require("config.utils.keymaps")
require("config.utils.autocmds_ft")

-- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Sessions -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- --
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "BufWinEnter", "LspAttach" }, {
  group = vim.api.nvim_create_augroup("UserBufferRoot", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    local root = utils.FindGoProjectRoot()
    if root and root ~= "" then
      vim.api.nvim_set_current_dir(root)
    end
  end,
})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = utils.LoadSession,
})
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = vim.api.nvim_create_augroup("AutoSessionGitRoot", { clear = true }),
  callback = utils.SaveSessionAtGitRoot,
})
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = utils.LoadSession,
})
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    local pane = os.getenv("TMUX_PANE")
    if pane then
      os.execute("tmux set-window-option -t " .. pane .. " automatic-rename on")
    end
  end,
})
local group = vim.api.nvim_create_augroup("SessionCwdRestore", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete" }, {
  group = group,
  callback = function()
    vim.schedule(utils.RestoreCWDFromSession)
  end,
})

-- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Sops auto decrypt/encrypt small fix --
-- -- -- -- -- -- -- -- -- -- -- -- -- --
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*/secrets/**/*enc*.yaml",
  callback = function(args)
    if not vim.b[args.buf].sops_first_open_done then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_win_set_cursor(0, { 1, 0 })
          vim.b[args.buf].sops_first_open_done = true
        end
      end)
      -- vim.b[args.buf].autoformat = false for removal
    end
  end,
})

-- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Visuals  -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- --
local visual_timer = nil
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:[vV\x16]*",
  callback = function()
    if visual_timer then
      visual_timer:stop()
    end

    visual_timer = vim.defer_fn(function()
      local mode = vim.api.nvim_get_mode().mode
      if mode:find("[vV\x16]") then
        vim.api.nvim_set_hl(0, "Normal", { bg = "#2c323c", force = true })
        vim.api.nvim_set_hl(0, "Visual", { bg = "#121417", bold = true, force = true })
        vim.cmd("redraw")
      end
      visual_timer = nil
    end, 20)
  end,
})
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV\x16]*:*",
  callback = function()
    if visual_timer then
      visual_timer:stop()
      visual_timer = nil
    end

    vim.schedule(function()
      local mode = vim.api.nvim_get_mode().mode
      if not mode:find("[vV\x16]") then
        vim.api.nvim_set_hl(0, "Normal", { link = "Normal" })
        vim.cmd("colorscheme " .. vim.g.colors_name)
        vim.cmd("redraw")
      end
    end)
  end,
})
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.opt.guicursor = "a:ver20"
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      return
    end

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local trailing_lines = vim.api.nvim_buf_get_lines(0, current_line, -1, false)

    for _, line in ipairs(trailing_lines) do
      local clean_line = line:gsub("%s", "")
      if #clean_line > 0 then
        return
      end
    end

    vim.defer_fn(function()
      vim.cmd("startinsert")
      vim.opt.guicursor = "v:hor20-Cursor,i:ver25,t:ver25,c:ver20"
    end, 10)
  end,
})
vim.api.nvim_set_hl(0, "CursorLine", {
  bg = "#3a3f4b",
})

-- -- -- -- -- -- -- -- -- -- -- -- -- --
-- OTHERS   -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- --
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    if string.find(vim.bo.filetype, "kulala_ui") then
      local win_id = vim.api.nvim_get_current_win()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win_id) then
          pcall(function()
            vim.api.nvim_win_close(win_id, false)
          end)
        end
      end)
    end
  end,
})
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = { "jar://*", "jrt://*" },
  callback = function(args)
    utils.ReadJar(args)
  end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      return
    end

    local reg = vim.v.event.regname
    reg = reg == "" and '"' or reg

    local text = vim.fn.getreg(reg)
    local width = vim.api.nvim_win_get_width(0)
    local lines = vim.split(text, "\n", { plain = true })

    local result = {}
    local join_next = false

    for _, line in ipairs(lines) do
      if join_next then
        result[#result] = result[#result] .. line
      else
        result[#result + 1] = line
      end

      join_next = vim.fn.strdisplaywidth(line) == width
    end

    local fixed = table.concat(result, "\n")
    local regtype = vim.fn.getregtype(reg)

    vim.fn.setreg(reg, fixed, regtype)
    vim.fn.setreg("+", fixed, regtype)
  end,
})
local tab_reload_group = vim.api.nvim_create_augroup("TabReloadGroup", { clear = true })
local visited_tabs = {}
vim.api.nvim_create_autocmd("TabEnter", {
  group = tab_reload_group,
  pattern = "*",
  callback = function()
    local current_tab = vim.api.nvim_get_current_tabpage()
    if not visited_tabs[current_tab] then
      visited_tabs[current_tab] = true
      vim.schedule(function()
        pcall(vim.cmd, "e")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("TabClosed", {
  group = tab_reload_group,
  pattern = "*",
  callback = function()
    local open_tabs = vim.api.nvim_list_tabpages()
    local open_tabs_set = {}
    for _, tab in ipairs(open_tabs) do
      open_tabs_set[tab] = true
    end

    for tab_id in pairs(visited_tabs) do
      if not open_tabs_set[tab_id] then
        visited_tabs[tab_id] = nil
      end
    end
  end,
})

local buffers = {}
local initialized = false
vim.api.nvim_create_autocmd("BufAdd", {
  callback = function(args)
    if not initialized then
      buffers = vim.api.nvim_list_bufs()
      initialized = true
      return
    end

    for _, buf in ipairs(buffers) do
      if buf == args.buf then
        return
      end
    end

    buffers = vim.api.nvim_list_bufs()

    local file = vim.api.nvim_buf_get_name(args.buf)

    if file == "" or vim.fn.filereadable(file) == 0 then
      return
    end

    if #Snacks.picker.get({ source = "explorer" }) > 0 then
      return
    end

    vim.schedule(function()
      Snacks.explorer({ cwd = keymap_utils.GetCWD(file) })
    end)
  end,
})
local function reset_go_colors()
  local go_groups = {
    "@function.go",
    "@function.call.go",
    "@method.go",
    "@method.call.go",
    -- "@type.go",
    -- "@module.go",
    "@type.builtin.go",
    "@variable.go",
    "@variable.parameter.go",
    "@variable.member.go",
    "@property.go",
    "@constant.go",
    -- "@operator.go",
    -- "@punctuation.bracket.go",
    "@punctuation.delimiter.go",
    -- "@comment.go",
    -- "@string.go",
    -- "@number.go",
    "@spell.go",
    "@function.method.call.go",
    "@function.method.go",
    "@constant.builtin.go",
    "@function.builtin.go",
    "@lsp.typemod.function.defaultLibrary.go",
    "@character.printf",

    "@lsp.string.go",
    "@lsp.type.function.go",
    "@lsp.type.method.go",
    "@lsp.type.number.go",
    "@lsp.type.variable.go",
    "@lsp.type.property.go",
    -- "@lsp.type.type.go",
    "@lsp.type.interface.go",
    "@lsp.type.struct.go",
    "@lsp.type.parameter.go",
    "@lsp.type.macro.go",
    "@lsp.type.namespace.go",
    "@lsp.type.keyword.go",
    -- "@keyword.go",
    -- "@keyword.return.go",
    -- "@keyword.switch.go",
    -- "@keyword.import.go",
    -- "@keyword.package.go",
    -- "@keyword.chan.go",
    -- "@keyword.struct.go",
    -- "@keyword.type.go",
    -- "@keyword.new.go",
    -- "@keyword.for.go",
    -- "@keyword.if.go",
    -- "@keyword.conditional.go",
    -- "@keyword.repeat.go",
    -- "@keyword.function.go",

    "@lsp.type.comment.go",
    "@type.definition.go",
    "@lsp.typemod.variable.definition.go",
    "@lsp.typemod.variable.interface.go",
    "@lsp.typemod.variable.static.go",
    "@lsp.typemod.variable.defaultLibrary.go",
    "@lsp.typemod.method.defaultLibrary.go",
    "@lsp.mod.static.go",
    "@lsp.mod.interface.go",
    "@lsp.mod.definition.go",
    "@lsp.type.variable.go",
    "@lsp.type.string.go",
  }
  -- vim.hl.priorities.semantic_tokens = 95

  for _, group in ipairs(go_groups) do
    vim.api.nvim_set_hl(0, group, { fg = "NONE", bg = "NONE", ctermfg = "NONE", ctermbg = "NONE", force = true })
  end

  -- "@keyword.type.go",
  vim.api.nvim_set_hl(0, "@type.builtin.go", { fg = "#e5c07b", force = true })
  vim.api.nvim_set_hl(0, "@type.definition.go", { fg = "NONE", force = true })
  vim.api.nvim_set_hl(0, "@lsp.type.namespace.go", { fg = "#e5c07b", force = true })
  -- vim.api.nvim_set_hl(0, "@string", { fg = "#d19a66", force = true })
  vim.api.nvim_set_hl(0, "@number.go", { fg = "#98c379", force = true })
  -- vim.api.nvim_set_hl(0, "@lsp.type.interface.go", { link = "@type.go" })
  -- vim.api.nvim_set_hl(0, "@lsp.type.interface.go", { fg = "#8be9fd", bold = true })
  -- vim.api.nvim_set_hl(0, "@lsp.type.struct.go", { fg = "#bd93f9" })
  -- vim.api.nvim_set_hl(0, "@string.go", { fg = "#f1fa8c" })
  -- vim.api.nvim_set_hl(0, "@comment.go", { fg = "#6272a4" })
end

reset_go_colors()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = reset_go_colors,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "http", "kulala_ui" }, -- срабатывает в окнах Kulala
  callback = function()
    vim.keymap.set("n", "<C-h>", "<Cmd>wincmd h<CR>", { buffer = true, desc = "Go to Left Window" })
    vim.keymap.set("n", "<C-l>", "<Cmd>wincmd l<CR>", { buffer = true, desc = "Go to Right Window" })
    vim.keymap.set("n", "V", function()
      vim.cmd("normal! V")
    end, { buffer = true, desc = "V" })
    vim.keymap.set("n", "A", function()
      vim.cmd("normal! V")
    end, { buffer = true, desc = "A" })
    vim.keymap.set("n", "tn", require("kulala.ui").show_next_tab, { buffer = true, desc = "Next Tab" })
    vim.keymap.set("n", "tp", require("kulala.ui").show_previous_tab, { buffer = true, desc = "Next Tab" })
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("FocusKulalaResponse", { clear = true }),
  pattern = "*",
  callback = function(args)
    if args.file == "kulala://ui" then
      local win = vim.fn.bufwinid(args.buf)
      if win ~= -1 then
        vim.schedule(function()
          vim.defer_fn(function()
            vim.api.nvim_set_current_win(win)
          end, 5)
        end)
      end
    end
  end,
})
