local M = {}

M.active_job = nil
M.timed_out = false

function M.run(cmd, opts)
  opts = opts or {}

  if M.active_job then
    M.stop()
  end

  M.timed_out = false
  local stdout_chunks = {}

  M.active_job = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,

    on_stdout = function(_, data, _)
      if data and opts.on_stdout then
        vim.schedule(function()
          for _, chunk in ipairs(data) do
            if chunk ~= "" then
              table.insert(stdout_chunks, chunk)
              opts.on_stdout(chunk, stdout_chunks)
            end
          end
        end)
      end
    end,

    on_stderr = function(_, data, _)
      if data and opts.on_stderr then
        vim.schedule(function()
          for _, chunk in ipairs(data) do
            if chunk ~= "" then
              opts.on_stderr(chunk)
            end
          end
        end)
      end
    end,

    on_exit = function(_, code, _)
      vim.schedule(function()
        M.active_job = nil
        if M.timed_out then
          return
        end
        if opts.on_exit then
          opts.on_exit(code, stdout_chunks)
        end
      end)
    end,
  })

  if M.active_job <= 0 then
    M.active_job = nil
    if opts.on_error then
      opts.on_error("Failed to start job")
    end
    return nil
  end

  if opts.timeout then
    vim.defer_fn(function()
      if M.active_job then
        M.timed_out = true
        M.stop()
        if opts.on_error then
          opts.on_error("Job timed out after " .. (opts.timeout / 1000) .. "s")
        end
      end
    end, opts.timeout)
  end

  return M.active_job
end

function M.stop()
  if M.active_job then
    vim.fn.jobstop(M.active_job)
    M.active_job = nil
  end
end

function M.is_running()
  return M.active_job ~= nil
end

return M
