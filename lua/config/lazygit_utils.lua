local Terminal = require("toggleterm.terminal").Terminal

local M = {}
local lazygit

function M.ToggleLazygit()
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
          [[<C-\><C-n><cmd>lua require("config.lazygit_utils").ToggleLazygit()<CR>]], { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "n", "<C-g>",
          [[<cmd>lua require("config.lazygit_utils").ToggleLazygit()<CR>]], { noremap = true, silent = true })
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

vim.keymap.set("n", "<C-g>", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  M.ToggleLazygit()
end, { noremap = true, silent = true })

local resize_timer = vim.uv and vim.uv.new_timer() or vim.loop.new_timer()
vim.api.nvim_create_autocmd({ "WinResized" }, {
  callback = function()
    if not (lazygit and lazygit:is_open()) then
      return
    end

    resize_timer:stop()

    resize_timer:start(
      150,
      0,
      vim.schedule_wrap(function()
        if lazygit and lazygit:is_open() then
          M.ToggleLazygit()
          M.ToggleLazygit()
        end
      end)
    )
  end,
})

return M
