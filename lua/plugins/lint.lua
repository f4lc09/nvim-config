return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Отключаем все линтеры для Go через nvim-lint
      linters_by_ft = {
        go = {}, -- Пустая таблица отключает все линтеры для Go
      },
    },
  },
}
