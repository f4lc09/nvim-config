return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- Установка переменной темы (хотя вы сказали, что она не помогает, пусть будет)
    vim.g.VM_theme = "ocean"

    -- Убедитесь, что LazyVim не удаляет этот файл из конфигурации
  end,
  config = function()
    -- Этот код будет выполняться каждый раз при смене цветовой схемы
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Группа для *курсора* в режиме выделения (VM_Cursor)
        -- Делаем его ярко-красным с черным текстом для максимальной видимости
        vim.api.nvim_set_hl(0, "VM_Cursor", {
          fg = "#000000", -- Черный текст
          bg = "#FF0000", -- Ярко-красный фон
          force = true, -- Принудительно переопределить все
        })

        -- Группа для *курсора* в режиме вставки (VM_Insert)
        -- Делаем его ярко-зеленым с черным текстом
        vim.api.nvim_set_hl(0, "VM_Insert", {
          fg = "#000000",
          bg = "#00FF00",
          force = true,
        })

        -- Группа для самого *выделения* (VM_Extend)
        -- Делаем фон серым, чтобы текст на нем был виден
        vim.api.nvim_set_hl(0, "VM_Extend", {
          bg = "#555555",
          force = true,
        })
      end,
    })
  end,
}
