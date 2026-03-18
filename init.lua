require("config.lazy")

vim.g.AutoPairs = 0
vim.o.showtabline = 2
vim.o.smartindent = false
vim.o.autoindent = false
vim.o.cindent = true
vim.o.showtabline = 2
vim.o.shada = [[!,'5000,<50,s10,h]]
vim.o.fixendofline = false
vim.o.timeoutlen = 1000
vim.o.tabstop = 4
vim.o.wrap = true
vim.o.swapfile = false

vim.lsp.set_log_level("error") -- Будет показывать только ошибки
