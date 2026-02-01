local M = {}

function M.get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local end_line = end_pos[2]

  if start_line == 0 or end_line == 0 then
    return nil
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  local indent = M.detect_indent(lines)

  return {
    bufnr = bufnr,
    start_line = start_line,
    end_line = end_line,
    lines = lines,
    text = table.concat(lines, "\n"),
    indent = indent,
  }
end

function M.detect_indent(lines)
  local min_indent = nil

  for _, line in ipairs(lines) do
    if line:match("%S") then
      local spaces = line:match("^(%s*)")
      local count = #spaces
      if min_indent == nil or count < min_indent then
        min_indent = count
      end
    end
  end

  return min_indent or 0
end

return M
