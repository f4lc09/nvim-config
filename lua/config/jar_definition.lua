local M = {}
local api = vim.api

local isDebug = false
local function debug(...)
  if isDebug then
    print("[jar_definition]", ...)
  end
end

local function is_jar(buf)
  local name = api.nvim_buf_get_name(buf)

  return vim.startswith(name, "jar://") or vim.startswith(name, "jrt://")
end

local function get_qualified_name(line, col)
  local start = col + 1
  local finish = col + 1

  while start > 1 do
    local c = line:sub(start - 1, start - 1)

    if not c:match("[%w_%.]") then
      break
    end

    start = start - 1
  end

  while finish <= #line do
    local c = line:sub(finish, finish)

    if not c:match("[%w_%.]") then
      break
    end

    finish = finish + 1
  end

  local value = line:sub(start, finish - 1)

  value = value:gsub("^%.+", "")
  value = value:gsub("%.+$", "")

  return value
end

local function make_snippet(qname)
  local simple_name = qname:match("([%w_]+)$")

  local lines = {
    "package com.example.receipterclient",
    "",
    "import " .. qname,
    "",
    "fun __nvim_lookup(value: " .. simple_name .. "?) {}",
    "",
  }

  debug("snippet:")

  for _, line in ipairs(lines) do
    debug(line)
  end

  return lines
end

local function find_position(lines, name)
  for row, line in ipairs(lines) do
    local col = line:find(name, 1, true)

    if col then
      return {
        line = row - 1,
        character = col - 1,
      }
    end
  end

  return nil
end

local function cleanup(buf, path)
  if buf and api.nvim_buf_is_valid(buf) then
    api.nvim_buf_delete(buf, {
      force = true,
    })
  end

  if path then
    vim.fn.delete(path)
  end
end

local function show_definition(result, client)
  if not result or (vim.islist(result) and #result == 0) then
    debug("Definition not found")
    return
  end

  local location = vim.islist(result) and result[1] or result

  if not location or not location.uri then
    debug("Invalid definition location")
    return
  end

  debug("opening definition:", location.uri)

  vim.lsp.util.show_document(location, client.offset_encoding, {
    reuse_win = true,
    focus = true,
  })
end

local function wait_for_lsp(buf, timeout)
  return vim.wait(timeout, function()
    if not api.nvim_buf_is_valid(buf) then
      return true
    end

    local clients = vim.lsp.get_clients({
      bufnr = buf,
      name = "kotlin_lsp",
    })

    return #clients > 0
  end, 20)
end

function M.definition()
  local source_buf = api.nvim_get_current_buf()

  if not is_jar(source_buf) then
    vim.lsp.buf.definition()
    return
  end

  debug("==========================================")
  debug("JAR DEFINITION")

  local source_uri = api.nvim_buf_get_name(source_buf)

  debug("source:", source_uri)
  debug("buf:", source_buf)

  local client = vim.lsp.get_clients({
    name = "kotlin_lsp",
  })[1]

  if not client then
    debug("kotlin_lsp not found")
    return
  end

  debug("client:", client.id, client.name)

  local cursor = api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local line = api.nvim_buf_get_lines(source_buf, row, row + 1, false)[1] or ""

  debug("cursor:", row, col)
  debug("line:", line)

  local qname = get_qualified_name(line, col)

  debug("qualified:", qname)

  if qname == "" then
    debug("No symbol under cursor")
    return
  end

  local simple_name = qname:match("([%w_]+)$")

  debug("simple name:", simple_name)

  local lines = make_snippet(qname)

  local position = find_position(lines, simple_name)

  if not position then
    debug("Cannot find lookup position")
    return
  end

  debug("definition position:", position.line, position.character)

  local root = client.config.root_dir

  if type(root) ~= "string" or root == "" then
    root = vim.fn.getcwd()
  end

  debug("root:", root)

  local source_files = vim.fs.find(function(name)
    return name:match("%.kt$") ~= nil
  end, {
    path = root,
    type = "file",
    limit = 1,
  })

  if #source_files == 0 then
    debug("No Kotlin source file found")
    return
  end

  local source_file = source_files[1]
  local source_dir = vim.fn.fnamemodify(source_file, ":h")

  debug("source file:", source_file)
  debug("source dir:", source_dir)

  local temp_path = source_dir .. "/.nvim_jar_lookup_" .. tostring(vim.uv.hrtime()) .. ".kt"

  debug("TEMP FILE:", temp_path)

  vim.fn.writefile(lines, temp_path)

  -- ============================================================
  -- HIDDEN BUFFER
  -- ============================================================

  local temp_buf = vim.fn.bufadd(temp_path)

  debug("TEMP BUF:", temp_buf)

  -- Загружаем buffer, но НЕ переключаем окно.
  vim.fn.bufload(temp_buf)

  if not api.nvim_buf_is_valid(temp_buf) then
    debug("Failed to create temp buffer")
    vim.fn.delete(temp_path)
    return
  end

  vim.bo[temp_buf].filetype = "kotlin"
  vim.bo[temp_buf].bufhidden = "wipe"
  vim.bo[temp_buf].swapfile = false
  vim.bo[temp_buf].modified = false

  debug("TEMP NAME:", api.nvim_buf_get_name(temp_buf))
  debug("TEMP FT:", vim.bo[temp_buf].filetype)

  -- ============================================================
  -- WAIT ONLY FOR LSP ATTACH
  -- ============================================================

  debug("waiaing for LSP attach...")

  local attached = wait_for_lsp(temp_buf, 10000)

  if not attached then
    debug("Kotlin LSP did not attach")

    cleanup(temp_buf, temp_path)
    return
  end

  local lookup_clients = vim.lsp.get_clients({
    bufnr = temp_buf,
    name = "kotlin_lsp",
  })

  local lookup_client = lookup_clients[1]

  if not lookup_client then
    debug("Kotlin LSP disappeared")
    cleanup(temp_buf, temp_path)
    return
  end

  debug("LSP ATTACHED:", lookup_client.id)
  debug("LSP ROOT:", lookup_client.config.root_dir)

  local temp_uri = vim.uri_from_bufnr(temp_buf)

  debug("TEMP URI:", temp_uri)

  -- ============================================================
  -- DEFINITION
  -- ============================================================

  debug("REQUEST definition")
  debug("position:", position.line, position.character)

  lookup_client:request("textDocument/definition", {
    textDocument = {
      uri = temp_uri,
    },

    position = position,
  }, function(err, result)
    debug("DEFINITION ERROR:", vim.inspect(err))
    debug("DEFINITION RESULT:", vim.inspect(result))

    vim.schedule(function()
      cleanup(temp_buf, temp_path)

      if err then
        debug("LSP ERROR:", vim.inspect(err))

        return
      end

      show_definition(result, lookup_client)
    end)
  end, temp_buf)
end

function M.setup()
  vim.keymap.set("n", "gd", M.definition, {
    desc = "Goto Definition",
  })
end

return M
