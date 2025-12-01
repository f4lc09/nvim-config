return {
  {
    "tpope/vim-fugitive",
  },
  {
    "shumphrey/fugitive-gitlab.vim",
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      vim.g.fugitive_gitlab_domains = { "gitlab.wildberries.ru" }
      vim.cmd("delcommand Gbrowse")
    end,
  },
}
