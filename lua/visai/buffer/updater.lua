local M = {}

M.state = nil

function M.start(sel)
  M.state = {
    bufnr = sel.bufnr,
    start_line = sel.start_line,
    end_line = sel.end_line,
    original_lines = sel.lines,
    indent = sel.indent,
    current_lines = {},
    first_update = true,
  }
end

function M.update(text)
  if not M.state then
    return
  end

  local lines = M.parse_lines(text)
  if #lines == 0 then
    return
  end

  lines = M.apply_indent(lines, M.state.indent)
  M.state.current_lines = lines

  vim.schedule(function()
    if not M.state then
      return
    end

    local bufnr = M.state.bufnr
    if not vim.api.nvim_buf_is_valid(bufnr) then
      M.state = nil
      return
    end

    if M.state.first_update then
      M.state.first_update = false
    else
      pcall(vim.cmd, "undojoin")
    end

    local start_idx = M.state.start_line - 1
    local end_idx = M.state.start_line - 1 + #M.state.original_lines

    if M.state.last_line_count then
      end_idx = M.state.start_line - 1 + M.state.last_line_count
    end

    vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
    M.state.last_line_count = #lines
  end)
end

function M.finish(text)
  if not M.state then
    return
  end

  local lines = M.parse_lines(text)
  if #lines > 0 then
    lines = M.apply_indent(lines, M.state.indent)
    M.state.current_lines = lines

    vim.schedule(function()
      if not M.state then
        return
      end

      local bufnr = M.state.bufnr
      if not vim.api.nvim_buf_is_valid(bufnr) then
        M.state = nil
        return
      end

      pcall(vim.cmd, "undojoin")

      local start_idx = M.state.start_line - 1
      local end_idx = M.state.start_line - 1 + #M.state.original_lines

      if M.state.last_line_count then
        end_idx = M.state.start_line - 1 + M.state.last_line_count
      end

      vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
      M.state = nil
    end)
  else
    M.state = nil
  end
end

function M.cancel()
  if not M.state then
    return
  end

  vim.schedule(function()
    if not M.state then
      return
    end

    local bufnr = M.state.bufnr
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.cmd, "undojoin")

      local start_idx = M.state.start_line - 1
      local end_idx = M.state.start_line - 1 + (M.state.last_line_count or #M.state.original_lines)

      vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, M.state.original_lines)
    end

    M.state = nil
  end)
end

function M.parse_lines(text)
  if not text or text == "" then
    return {}
  end

  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end

  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  return lines
end

function M.apply_indent(lines, indent)
  if indent <= 0 then
    return lines
  end

  local prefix = string.rep(" ", indent)
  local result = {}

  for _, line in ipairs(lines) do
    if line == "" then
      table.insert(result, "")
    else
      table.insert(result, prefix .. line)
    end
  end

  return result
end

return M
