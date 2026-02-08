local base = require("visai.providers.base")

local function clean_output(text)
  if not text then
    return ""
  end

  local result = text
  -- Remove OSC sequences (ESC ] ... BEL or ESC ] ... ESC \)
  result = result:gsub("\027%].-\007", "")
  result = result:gsub("\027%].-\027\\", "")
  -- Remove CSI sequences (ESC [ ... letter)
  result = result:gsub("\027%[%?[%d;]*[A-Za-z]", "")
  result = result:gsub("\027%[%<[%d;]*[A-Za-z]", "")
  result = result:gsub("\027%[[%d;]*[A-Za-z]", "")
  -- Remove any remaining ESC sequences
  result = result:gsub("\027[^%[%]]?[%w]*", "")
  -- Remove BEL
  result = result:gsub("\007", "")
  -- Remove carriage returns
  result = result:gsub("\r", "")
  -- Remove markdown code blocks
  result = result:gsub("^```[%w]*\n", "")
  result = result:gsub("\n```%s*$", "")
  -- Trim leading/trailing whitespace
  result = result:gsub("^%s+", "")
  result = result:gsub("%s+$", "")

  return result
end

local provider = base.new({
  name = "claude-code",
  cmd = "claude",

  build_cmd = function(self, prompt)
    local escaped = prompt:gsub("'", "'\\''")
    return { "sh", "-c", "echo '" .. escaped .. "' | " .. self.cmd .. " -p" }
  end,

  parse_output = function(self, text)
    return clean_output(text)
  end,
})

return provider
