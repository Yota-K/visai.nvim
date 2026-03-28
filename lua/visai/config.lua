local M = {}

M.defaults = {
  provider = "claude-code",
  keymap = "ae",
  -- Benchmark results (claude -p, 5 runs each):
  --   small  (5 lines):  mean 3.9s, P95  4.6s
  --   medium (12 lines): mean 6.0s, P95  6.8s
  --   large  (35 lines): mean 10.0s, P95 12.0s
  -- 20s = P95(12s) + 50% margin, rounded up for stability.
  -- Responses exceeding this are likely too complex and may cause
  -- buffer corruption due to chunked escape sequence splitting.
  timeout = 20000,
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
