local M = {}

local config = require("visai.config")

function M.open(on_submit)
  local cfg = config.get()
  local win_cfg = cfg.window

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

  local width = win_cfg.width
  local height = win_cfg.height
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = win_cfg.border,
    title = win_cfg.title,
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win_id, "wrap", true)
  vim.api.nvim_win_set_option(win_id, "cursorline", false)

  vim.cmd("startinsert")

  local function close()
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
  end

  local function submit()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local text = vim.trim(table.concat(lines, "\n"))
    close()
    if on_submit then
      on_submit(text)
    end
  end

  vim.keymap.set("n", "<Esc>", close, { buffer = bufnr })
  vim.keymap.set("n", "q", close, { buffer = bufnr })
  vim.keymap.set({ "n", "i" }, "<C-s>", submit, { buffer = bufnr })
  vim.keymap.set({ "n", "i" }, "<C-c>", close, { buffer = bufnr })
  vim.keymap.set("i", "<C-CR>", submit, { buffer = bufnr })
end

return M
