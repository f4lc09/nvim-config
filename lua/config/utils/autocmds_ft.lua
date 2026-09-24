local utils = require("config.utils.autocmds")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(args)
    utils.SetupKulalaKeymaps(args.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    utils.SetupGoTestKeymaps(args.buf)
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "json", "rest", "graphql" },
  command = "set conceallevel=0",
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "yaml", "kotlin" },
  callback = function()
    vim.b.autoformat = false
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.b.ale_enabled = 1
  end,
})
