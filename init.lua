vim.o.shada = [[!,'5000,<50,s10,h]]

require("config.lazy")
require("config.autocmds")
require("config.utils.jar_definition")

local node_bin_path = "/home/falcon/.nvm/versions/node/v24.15.0/bin/node"
vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH

-- vim.o.tabstop = 4 for removal
vim.o.showtabline = 0
vim.o.smartindent = false
vim.o.autoindent = false
vim.o.cindent = true
vim.o.fixendofline = false
vim.o.timeoutlen = 1000
vim.o.wrap = true
vim.o.swapfile = false

vim.lsp.set_log_level("error")
vim.g.root_spec = { { ".git", "lua" }, "cwd", "lsp" }
vim.g.go_debug_log_output = ""
vim.o.conceallevel = 0
vim.g.ale_enabled = 0
vim.opt.guicursor:append("v:hor20-Cursor,t:ver25,c:ver20")
vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardOpened",
  callback = function(args)
    vim.api.nvim_clear_autocmds({
      event = "WinResized",
      group = "snacks_dashboard",
    })
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

    vim.schedule(function()
      Snacks.explorer()
    end)
  end,
})
