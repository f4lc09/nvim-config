require("config.lazy")

vim.opt.langmap =
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчняж;abcdefghijklmnopqrstuvwxyz:"

require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" },
  },
})

vim.api.nvim_create_user_command("Dapui", function()
  require("dapui").toggle()
end, { desc = "Toggle nvim-dap-ui visibility", nargs = 0 })
vim.o.smartindent = false
vim.o.autoindent = false
vim.o.cindent = true

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "http", "json", "rest", "graphql" },
  command = "set conceallevel=0",
})
vim.opt.tabstop = 4
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
  fg = "#4D73A3",
})
vim.o.fixendofline = false
