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
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if not vim.bo[buf].swapfile and vim.bo[buf].bufhidden ~= "" then
      return
    end
    local path = vim.api.nvim_buf_get_name(buf)
    if path:match("[/\\]%.local[/\\]share[/\\]nvim[/\\]scratch[/\\]") then
      return
    end
    -- Skipping explorer sources
    -- local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
    -- if prev_win ~= 0 then
    --   local prev_buf = vim.api.nvim_win_get_buf(prev_win)
    --   print(vim.bo[prev_buf].filetype)
    --
    --   if vim.bo[prev_buf].filetype == "snacks_picker_list" or vim.bo[prev_buf].filetype == "snacks_picker_input" then
    --     return
    --   end
    -- end

    Snacks.explorer({ cwd = keymap_utils.GetCWD() })
  end,
})

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local name = vim.api.nvim_buf_get_name(args.buf)
--
--     if name:match("^diffview://") then
--       vim.lsp.buf_detach_client(args.buf, args.data.client_id)
--     end
--   end,
-- })
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
