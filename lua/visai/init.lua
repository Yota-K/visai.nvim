local M = {}

local config = require("visai.config")
local selection = require("visai.selection")
local runner = require("visai.job.runner")

function M.setup(opts)
  config.setup(opts)

  local cfg = config.get()

  vim.api.nvim_create_user_command("Visai", function()
    M.edit()
  end, { range = true })

  if cfg.keymap then
    vim.keymap.set("v", cfg.keymap, ":<C-u>lua require('visai').edit()<CR>", {
      desc = "Visai: Edit selection with AI",
      silent = true,
    })
  end
end

function M.edit()
  local sel = selection.get_visual_selection()
  if not sel then
    vim.notify("No selection found", vim.log.levels.WARN)
    return
  end

  local input = require("visai.ui.input")
  input.open(function(instruction)
    if not instruction or instruction == "" then
      return
    end
    M.execute(sel, instruction)
  end)
end

function M.execute(sel, instruction)
  local providers = require("visai.providers")
  local updater = require("visai.buffer.updater")
  local progress = require("visai.ui.progress")
  local cfg = config.get()

  local provider = providers.get(cfg.provider)
  if not provider then
    vim.notify("Provider not found: " .. cfg.provider, vim.log.levels.ERROR)
    return
  end

  if not provider:is_available() then
    vim.notify("Provider not available: " .. cfg.provider, vim.log.levels.ERROR)
    return
  end

  local prompt = provider:build_prompt(sel.text, instruction)
  local cmd = provider:build_cmd(prompt)

  progress.open()
  updater.start(sel)

  runner.run(cmd, {
    timeout = cfg.timeout,

    on_stdout = function(chunk, all_chunks)
      local text = table.concat(all_chunks, "\n")
      local parsed = provider:parse_output(text)
      updater.update(parsed)
    end,

    on_stderr = function(chunk)
    end,

    on_exit = function(code, all_chunks)
      if code == 0 then
        local text = table.concat(all_chunks, "\n")
        local parsed = provider:parse_output(text)
        updater.finish(parsed)
        progress.finish(true)
      else
        updater.cancel()
        progress.finish(false)
      end
    end,

    on_error = function(msg)
      updater.cancel()
      progress.finish(false)
    end,
  })
end

function M.cancel()
  runner.stop()
  local updater = require("visai.buffer.updater")
  local progress = require("visai.ui.progress")
  updater.cancel()
  progress.close()
end

return M
