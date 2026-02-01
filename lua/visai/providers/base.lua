local M = {}

function M.new(opts)
  local provider = {
    name = opts.name,
    cmd = opts.cmd,
    args = opts.args or {},
  }

  function provider:is_available()
    return vim.fn.executable(self.cmd) == 1
  end

  function provider:build_prompt(code, instruction)
    return string.format(
      [[You are a code editor. Edit the following code according to the instruction.
Output ONLY the edited code without any explanation or markdown formatting.

Instruction: %s

Code:
%s]],
      instruction,
      code
    )
  end

  function provider:build_cmd(prompt)
    error("build_cmd must be implemented")
  end

  function provider:parse_output(text)
    return text
  end

  for k, v in pairs(opts) do
    if type(v) == "function" then
      provider[k] = v
    end
  end

  return provider
end

return M
