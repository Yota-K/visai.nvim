local M = {}

function M.create_buffer(lines)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  return bufnr
end

function M.get_buffer_lines(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

function M.delete_buffer(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

function M.wait(ms)
  vim.wait(ms or 100)
end

function M.wait_until(condition, timeout)
  timeout = timeout or 1000
  local start = vim.loop.now()
  while not condition() do
    vim.wait(10)
    if vim.loop.now() - start > timeout then
      error("Timeout waiting for condition")
    end
  end
end

return M
