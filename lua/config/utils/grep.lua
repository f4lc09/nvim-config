local M = {}

function M.grep()
  vim.api.nvim_set_hl(0, "SnacksGrepMatch", {
    fg = vim.api.nvim_get_hl(0, {
      name = "SnacksDashboardHeader",
      link = false,
    }).fg,
    bg = "#626670",
    bold = true,
  })

  vim.api.nvim_set_hl(0, "SnacksGrepActiveLine", {
    bg = "#3a3f4b",
  })

  local match_ns = vim.api.nvim_create_namespace("snacks_grep_match")
  local active_ns = vim.api.nvim_create_namespace("snacks_grep_active")
  local ts_ns = vim.api.nvim_create_namespace("snacks_grep_ts")

  ----------------------------------------------------------------
  -- Statuscolumn
  ----------------------------------------------------------------

  _G.SnacksGrepStatusColumn = function()
    local buf = vim.api.nvim_get_current_buf()
    local numbers = vim.b[buf].grep_line_numbers

    if not numbers then
      return "        "
    end

    local number = numbers[vim.v.lnum]

    if not number then
      return "        "
    end

    local width = vim.b[buf].grep_line_nr_width or 5

    return string.format("%" .. width .. "d ", number)
  end

  local function item_key(item)
    return string.format(
      "%s:%s:%s:%s",
      item.file or "",
      item.pos and item.pos[1] or 0,
      item.pos and item.pos[2] or 0,
      item.end_pos and item.end_pos[2] or 0
    )
  end

  local function setup_preview_window(win)
    if not vim.api.nvim_win_is_valid(win) then
      return
    end

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldcolumn = "0"
    vim.wo[win].statuscolumn = "%{v:lua.SnacksGrepStatusColumn()}"
    vim.wo[win].cursorline = false
    vim.wo[win].wrap = false
  end

  ----------------------------------------------------------------
  -- Clear preview marks.
  ----------------------------------------------------------------

  local function clear_preview_marks(picker)
    local preview = picker.preview

    if not preview or not preview.win then
      return
    end

    local buf = preview.win.buf

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    vim.api.nvim_buf_clear_namespace(buf, match_ns, 0, -1)

    vim.api.nvim_buf_clear_namespace(buf, active_ns, 0, -1)

    vim.api.nvim_buf_clear_namespace(buf, ts_ns, 0, -1)

    vim.b[buf].grep_line_numbers = nil
    vim.b[buf].grep_line_nr_width = nil

    setup_preview_window(preview.win.win)
  end

  ----------------------------------------------------------------
  -- Active line.
  --
  -- Красим только то, что находится ВНЕ match.
  ----------------------------------------------------------------

  local function update_active_line(picker, item)
    local preview = picker.preview

    if not preview or not preview.win then
      return
    end

    local buf = preview.win.buf

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    local lines = picker._grep_item_lines

    if not lines or not item then
      return
    end

    local line = lines[item_key(item)]

    if line == nil then
      return
    end

    vim.api.nvim_buf_clear_namespace(buf, active_ns, 0, -1)

    local extmarks = vim.api.nvim_buf_get_extmarks(buf, match_ns, { line, 0 }, { line, -1 }, {
      details = true,
    })

    ----------------------------------------------------------------
    -- Нет match.
    ----------------------------------------------------------------

    if #extmarks == 0 then
      vim.api.nvim_buf_add_highlight(buf, active_ns, "SnacksGrepActiveLine", line, 0, -1)

      return
    end

    ----------------------------------------------------------------
    -- Active background только вне match.
    ----------------------------------------------------------------

    local cursor = 0

    for _, mark in ipairs(extmarks) do
      local start_col = mark[3]
      local details = mark[4]

      local end_col = details and details.end_col or start_col

      if start_col > cursor then
        vim.api.nvim_buf_add_highlight(buf, active_ns, "SnacksGrepActiveLine", line, cursor, start_col)
      end

      cursor = math.max(cursor, end_col)
    end

    vim.api.nvim_buf_add_highlight(buf, active_ns, "SnacksGrepActiveLine", line, cursor, -1)
  end

  Snacks.picker.grep({
    layout = {
      fullscreen = true,

      layout = {
        box = "vertical",

        {
          win = "input",
          height = 1,
          border = "rounded",
        },

        {
          box = "horizontal",
          border = "single",

          {
            win = "preview",
            height = 0,
            border = "right",
          },
          {
            win = "list",
            height = 0,
          },
        },
      },
    },

    ----------------------------------------------------------------
    -- Selection changed.
    --
    -- Если набор результатов тот же — ничего не перерисовываем.
    ----------------------------------------------------------------

    on_change = function(picker, item)
      if not item then
        picker._grep_signature = nil
        picker._grep_item_lines = nil
        picker._grep_line_numbers = nil

        clear_preview_marks(picker)

        return
      end

      update_active_line(picker, item)
    end,

    ----------------------------------------------------------------
    -- List format.
    ----------------------------------------------------------------

    format = function(item, picker)
      local icon, hl = Snacks.util.icon(item.file, "file")

      local file_hl = "Normal"
      local bufnr = vim.fn.bufnr(item.file)

      if bufnr ~= -1 then
        local main_buf = vim.api.nvim_win_is_valid(picker.main) and vim.api.nvim_win_get_buf(picker.main) or nil

        if bufnr == main_buf then
          file_hl = "SnacksPickerTitle"
        elseif vim.api.nvim_get_option_value("buflisted", {
          buf = bufnr,
        }) then
          file_hl = "SnacksDashboardKey"
        end
      end

      local filename = vim.fn.fnamemodify(item.file, ":t")
      local path = vim.fn.fnamemodify(item.file, ":.")

      return {
        { icon .. " ", hl },
        { filename, file_hl },
        { "\n" .. path, "Comment" },
      }
    end,

    ----------------------------------------------------------------
    -- Preview.
    ----------------------------------------------------------------

    preview = function(ctx)
      local picker = ctx.picker
      local win = ctx.preview.win.win
      local buf = ctx.preview.win.buf

      if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      setup_preview_window(win)

      local items = picker:items()

      ----------------------------------------------------------------
      -- No results.
      ----------------------------------------------------------------

      if #items == 0 then
        picker._grep_signature = nil
        picker._grep_item_lines = nil
        picker._grep_line_numbers = nil

        vim.api.nvim_buf_clear_namespace(buf, match_ns, 0, -1)

        vim.api.nvim_buf_clear_namespace(buf, active_ns, 0, -1)

        vim.api.nvim_buf_clear_namespace(buf, ts_ns, 0, -1)

        vim.b[buf].grep_line_numbers = nil
        vim.b[buf].grep_line_nr_width = nil

        setup_preview_window(win)

        return
      end

      ----------------------------------------------------------------
      -- Signature результатов.
      ----------------------------------------------------------------

      local signature_parts = {}

      for _, item in ipairs(items) do
        signature_parts[#signature_parts + 1] = item_key(item)
      end

      local signature = table.concat(signature_parts, "\n")

      ----------------------------------------------------------------
      -- Результаты те же.
      --
      -- Только перемещаем active line.
      ----------------------------------------------------------------

      if picker._grep_signature == signature then
        update_active_line(picker, ctx.item)

        setup_preview_window(win)

        return
      end

      picker._grep_signature = signature
      picker._grep_item_lines = {}
      picker._grep_line_numbers = {}

      ----------------------------------------------------------------
      -- Собираем максимальный номер строки.
      ----------------------------------------------------------------

      local max_line_nr = 0

      for _, item in ipairs(items) do
        if item.pos and item.pos[1] then
          max_line_nr = math.max(max_line_nr, item.pos[1])
        end
      end

      local line_nr_width = math.max(5, #tostring(max_line_nr))

      picker._grep_line_nr_width = line_nr_width

      ----------------------------------------------------------------
      -- Ширина preview с учётом statuscolumn.
      --
      -- "%5d │" = 5 цифр + пробел + │
      ----------------------------------------------------------------

      local gutter_width = line_nr_width + 2

      local total_width = vim.api.nvim_win_get_width(win)

      local width = math.max(1, total_width - gutter_width)

      ----------------------------------------------------------------
      -- Data.
      ----------------------------------------------------------------

      local lines = {}
      local matches = {}

      local cache = {}
      local parsers = {}
      local syntax = {}

      ----------------------------------------------------------------
      -- Collect lines.
      ----------------------------------------------------------------

      for _, item in ipairs(items) do
        if item.file and item.pos then
          local line_nr = item.pos[1]

          if not cache[item.file] then
            local ok, content = pcall(vim.fn.readfile, item.file)

            cache[item.file] = ok and content or {}
          end

          local line = cache[item.file][line_nr]

          if line then
            local preview_line = #lines

            lines[#lines + 1] = line

            matches[preview_line] = {
              start = item.pos[2] or 0,

              finish = item.end_pos and item.end_pos[2] or ((item.pos[2] or 0) + 1),
            }

            picker._grep_item_lines[item_key(item)] = preview_line

            picker._grep_line_numbers[preview_line + 1] = line_nr
          end
        end
      end

      ----------------------------------------------------------------
      -- display column -> byte offset.
      ----------------------------------------------------------------

      local function display_to_byte(line, target)
        if target <= 0 then
          return 0
        end

        local byte = 0
        local display = 0

        while byte < #line do
          local char = vim.fn.matchstr(line:sub(byte + 1), "^.")

          if char == "" then
            break
          end

          local char_width = vim.fn.strdisplaywidth(char)

          if display + char_width > target then
            break
          end

          display = display + char_width

          byte = byte + #char
        end

        return byte
      end

      ----------------------------------------------------------------
      -- Crop.
      ----------------------------------------------------------------

      local function crop_line(line, match_start, match_end)
        local line_width = vim.fn.strdisplaywidth(line)

        if line_width <= width then
          return line, 0
        end

        local match_start_display = vim.fn.strdisplaywidth(line:sub(1, match_start))

        local match_end_display = vim.fn.strdisplaywidth(line:sub(1, match_end))

        local crop_display = 0

        if match_end_display <= width then
          crop_display = 0
        elseif match_start_display < width then
          crop_display = 0
        else
          crop_display = match_end_display - width + 5
        end

        crop_display = math.max(0, math.min(crop_display, line_width - width))

        local start_byte = display_to_byte(line, crop_display)

        local end_byte = display_to_byte(line, crop_display + width)

        return line:sub(start_byte + 1, end_byte), start_byte
      end

      ----------------------------------------------------------------
      -- Crop каждой строки.
      ----------------------------------------------------------------

      local cropped_lines = {}
      local crop_offsets = {}

      for i, line in ipairs(lines) do
        local match = matches[i - 1]

        local cropped, offset = crop_line(line, match.start, match.finish)

        cropped_lines[i] = cropped
        crop_offsets[i] = offset
      end

      ----------------------------------------------------------------
      -- Tree-sitter.
      ----------------------------------------------------------------

      for _, item in ipairs(items) do
        if item.file and item.pos then
          local line_nr = item.pos[1]

          local line = cache[item.file] and cache[item.file][line_nr]

          if line then
            if parsers[item.file] == nil then
              parsers[item.file] = false

              local ft = vim.filetype.match({
                filename = item.file,
              })

              local lang = ft and vim.treesitter.language.get_lang(ft)

              if lang and vim.treesitter.language.add(lang) then
                local tsbuf = vim.api.nvim_create_buf(false, true)

                vim.api.nvim_buf_set_lines(tsbuf, 0, -1, false, cache[item.file])

                vim.bo[tsbuf].filetype = ft

                local ok, parser = pcall(vim.treesitter.get_parser, tsbuf, lang)

                if ok and parser then
                  parser:parse()

                  local query = vim.treesitter.query.get(lang, "highlights")

                  if query then
                    parsers[item.file] = {
                      buf = tsbuf,
                      parser = parser,
                      query = query,
                    }
                  else
                    vim.api.nvim_buf_delete(tsbuf, { force = true })
                  end
                else
                  vim.api.nvim_buf_delete(tsbuf, { force = true })
                end
              end
            end

            local ts = parsers[item.file]

            if ts then
              local tree = ts.parser:parse()[1]

              local preview_line = picker._grep_item_lines[item_key(item)]

              if preview_line then
                for id, node in ts.query:iter_captures(tree:root(), ts.buf, line_nr - 1, line_nr) do
                  local capture = ts.query.captures[id]

                  local row1, col1, row2, col2 = node:range()

                  if row1 <= line_nr - 1 and row2 >= line_nr - 1 then
                    local start_col = row1 == line_nr - 1 and col1 or 0

                    local end_col = row2 == line_nr - 1 and col2 or #line

                    syntax[preview_line] = syntax[preview_line] or {}

                    table.insert(syntax[preview_line], {
                      start_col,
                      end_col,
                      "@" .. capture,
                    })
                  end
                end
              end
            end
          end
        end
      end

      ----------------------------------------------------------------
      -- Render.
      ----------------------------------------------------------------

      ctx.preview:reset()
      ctx.preview:set_lines(cropped_lines)

      ----------------------------------------------------------------
      -- Snacks мог заменить preview buffer.
      ----------------------------------------------------------------

      buf = ctx.preview.win.buf

      vim.b[buf].grep_line_numbers = picker._grep_line_numbers

      vim.b[buf].grep_line_nr_width = picker._grep_line_nr_width

      setup_preview_window(win)

      ----------------------------------------------------------------
      -- Namespaces.
      ----------------------------------------------------------------

      vim.api.nvim_buf_clear_namespace(buf, ts_ns, 0, -1)

      vim.api.nvim_buf_clear_namespace(buf, match_ns, 0, -1)

      vim.api.nvim_buf_clear_namespace(buf, active_ns, 0, -1)

      ----------------------------------------------------------------
      -- Tree-sitter.
      ----------------------------------------------------------------

      for line_nr, highlights in pairs(syntax) do
        local offset = crop_offsets[line_nr + 1] or 0

        local cropped = cropped_lines[line_nr + 1] or ""

        for _, h in ipairs(highlights) do
          local start_col = h[1] - offset

          local end_col = h[2] - offset

          if end_col > 0 and start_col < #cropped then
            start_col = math.max(0, start_col)

            end_col = math.min(#cropped, end_col)

            if end_col > start_col then
              vim.api.nvim_buf_add_highlight(buf, ts_ns, h[3], line_nr, start_col, end_col)
            end
          end
        end
      end

      ----------------------------------------------------------------
      -- Match.
      ----------------------------------------------------------------

      for line_nr, match in pairs(matches) do
        local offset = crop_offsets[line_nr + 1] or 0

        local line = cropped_lines[line_nr + 1] or ""

        local start_col = math.max(0, match.start - offset)

        local end_col = math.min(#line, match.finish - offset)

        if start_col < end_col then
          vim.api.nvim_buf_set_extmark(buf, match_ns, line_nr, start_col, {
            end_col = end_col,
            hl_group = "SnacksGrepMatch",
          })
        end
      end

      ----------------------------------------------------------------
      -- Active line.
      ----------------------------------------------------------------

      update_active_line(picker, ctx.item)

      ----------------------------------------------------------------
      -- Statuscolumn.
      ----------------------------------------------------------------

      setup_preview_window(win)

      vim.cmd("redraw")

      ----------------------------------------------------------------
      -- Cleanup Tree-sitter buffers.
      ----------------------------------------------------------------

      for _, ts in pairs(parsers) do
        if ts then
          pcall(vim.api.nvim_buf_delete, ts.buf, { force = true })
        end
      end
    end,
  })
end

return M
