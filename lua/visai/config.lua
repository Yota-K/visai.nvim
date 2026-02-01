local M = {}

M.defaults = {
  provider = "claude-code",
  keymap = "ae",
  timeout = 300000,
  window = {
    width = 60,
    height = 3,
    border = "rounded",
    title = " Visai ",
  },
  providers = {
    ["claude-code"] = {
      cmd = "claude",
      args = { "-p", "--tools", "" },
    },
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

function M.get()
  return M.options
end

return M
