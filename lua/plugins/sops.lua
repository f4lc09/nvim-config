return {
  "trixnz/sops.nvim",
  lazy = false,
  config = function()
    require("sops").setup({
      on_attach = function(bufnr)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

        if buftype == "nofile" or filetype == "DiffviewFiles" or vim.wo.diff then
          return false
        end

        return true
      end,
    })
  end,
}
