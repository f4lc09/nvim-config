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
-- TODO: поправить статусную линию
-- TODO: diffview close on exit and fix gopls
-- TODO: починить <space>fp vim.wait()
-- local input_buffer = {}
-- local is_loading_snacks = true
-- local ns_id = vim.api.nvim_create_namespace("snacks_delay_buffer")
--
-- -- Перехватываем клавиши и складываем их в очередь
-- vim.on_key(function(key)
--   if is_loading_snacks and key and key ~= "" then
--     table.insert(input_buffer, key)
--     return "" -- «Гасим» немедленное выполнение, чтобы оно не сработало раньше времени
--   end
-- end, ns_id)
--
-- -- Слушаем загрузку snacks.nvim
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LazyLoad",
--   callback = function(event)
--     if event.data == "snacks.nvim" then
--       is_loading_snacks = false
--       vim.on_key(nil, ns_id) -- Полностью отключаем перехватчик
--
--       -- Если во время загрузки были нажатия, воспроизводим их по очереди
--       if #input_buffer > 0 then
--         local full_keys = table.concat(input_buffer)
--         -- 'm' означает запуск маппингов, 't' обрабатывает клавиши как прямой ввод пользователя
--         vim.api.nvim_feedkeys(full_keys, "mt", true)
--       end
--     end
--   end,
-- })
