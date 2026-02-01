local M = {}

local config = require("visai.config")

M.state = nil

function M.open()
  if M.state then
    M.close()
  end

  local cfg = config.get()
  local win_cfg = cfg.window

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  local width = win_cfg.width
  local height = win_cfg.height
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_id = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = win_cfg.border,
    title = " Processing... ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win_id, "wrap", true)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "AI is generating..." })
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  M.state = {
    bufnr = bufnr,
    win_id = win_id,
  }

  return M.state
end

function M.finish(success)
  if not M.state then
    return
  end

  local bufnr = M.state.bufnr
  local win_id = M.state.win_id

  if not vim.api.nvim_buf_is_valid(bufnr) then
    M.state = nil
    return
  end

  if vim.api.nvim_win_is_valid(win_id) then
    local title = success and " Complete " or " Error "
    vim.api.nvim_win_set_config(win_id, { title = title, title_pos = "center" })

    local msg = success and "Done! Press q or <Esc> to close" or "Failed. Press q or <Esc> to close"
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { msg })
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

    vim.keymap.set("n", "q", function()
      M.close()
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Esc>", function()
      M.close()
    end, { buffer = bufnr })

    vim.api.nvim_set_current_win(win_id)
  end
end

function M.close()
  if not M.state then
    return
  end

  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    vim.api.nvim_win_close(M.state.win_id, true)
  end

  M.state = nil
end

function M.is_open()
  return M.state ~= nil
end

return M
