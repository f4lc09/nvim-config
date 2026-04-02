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
-- Настройка цветов самого скроллбара
vim.api.nvim_set_hl(0, "ScrollbarHandle", { fg = "#ff9e64", bg = "#3b4261" })

-- Настройка меток поиска на скроллбаре (из hlslens)
vim.api.nvim_set_hl(0, "ScrollbarSearch", { fg = "#ff007c", bg = "NONE" })
