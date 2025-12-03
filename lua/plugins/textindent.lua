return {
  -- First, make sure the base dependency is loaded
  "kana/vim-textobj-user",

  -- Then, configure the indent plugin with the dependency listed
  {
    "kana/vim-textobj-indent",
    dependencies = { "kana/vim-textobj-user" },
  },
}
