local claude_code = require("visai.providers.claude-code")

describe("providers.claude-code", function()
  describe("parse_output", function()
    it("returns empty string for nil", function()
      local result = claude_code:parse_output(nil)
      assert.are.equal("", result)
    end)

    it("returns text unchanged when no special sequences", function()
      local result = claude_code:parse_output("hello world")
      assert.are.equal("hello world", result)
    end)

    it("removes ANSI color codes", function()
      local result = claude_code:parse_output("\027[31mred text\027[0m")
      assert.are.equal("red text", result)
    end)

    it("removes ANSI cursor movement sequences", function()
      local result = claude_code:parse_output("\027[2Ahello\027[3B")
      assert.are.equal("hello", result)
    end)

    it("removes OSC sequences with BEL terminator", function()
      local result = claude_code:parse_output("\027]0;title\007content")
      assert.are.equal("content", result)
    end)

    it("removes OSC sequences with ESC backslash terminator", function()
      local result = claude_code:parse_output("\027]0;title\027\\content")
      assert.are.equal("content", result)
    end)

    it("removes BEL characters", function()
      local result = claude_code:parse_output("hello\007world")
      assert.are.equal("helloworld", result)
    end)

    it("removes carriage returns", function()
      local result = claude_code:parse_output("hello\r\nworld")
      assert.are.equal("hello\nworld", result)
    end)

    it("removes markdown code block markers at start", function()
      local result = claude_code:parse_output("```lua\nlocal x = 1")
      assert.are.equal("local x = 1", result)
    end)

    it("removes markdown code block markers at end", function()
      local result = claude_code:parse_output("local x = 1\n```")
      assert.are.equal("local x = 1", result)
    end)

    it("removes markdown code block markers at both ends", function()
      local result = claude_code:parse_output("```lua\nlocal x = 1\n```")
      assert.are.equal("local x = 1", result)
    end)

    it("trims leading whitespace", function()
      local result = claude_code:parse_output("   hello")
      assert.are.equal("hello", result)
    end)

    it("trims trailing whitespace", function()
      local result = claude_code:parse_output("hello   ")
      assert.are.equal("hello", result)
    end)

    it("handles complex mixed content", function()
      local input = "\027[32m```python\n\027]0;title\007print('hello')\r\n```\027[0m  "
      local result = claude_code:parse_output(input)
      assert.are.equal("print('hello')", result)
    end)

    it("removes CSI sequences with question mark", function()
      local result = claude_code:parse_output("\027[?25lhello\027[?25h")
      assert.are.equal("hello", result)
    end)
  end)

  describe("build_cmd", function()
    it("builds command with echo and pipe", function()
      local result = claude_code:build_cmd("test prompt")
      assert.are.equal("sh", result[1])
      assert.are.equal("-c", result[2])
      assert.matches("echo 'test prompt'", result[3])
      assert.matches("claude %-p", result[3])
    end)

    it("escapes single quotes in prompt", function()
      local result = claude_code:build_cmd("don't break")
      assert.matches("don'\\''t break", result[3])
    end)

    it("escapes multiple single quotes", function()
      local result = claude_code:build_cmd("it's a 'test'")
      local cmd = result[3]
      assert.matches("it'\\''s a '\\''test'\\''", cmd)
    end)
  end)

  describe("is_available", function()
    it("checks if claude command exists", function()
      local result = claude_code:is_available()
      assert.is_boolean(result)
    end)
  end)

  describe("provider properties", function()
    it("has correct name", function()
      assert.are.equal("claude-code", claude_code.name)
    end)

    it("has correct cmd", function()
      assert.are.equal("claude", claude_code.cmd)
    end)
  end)
end)
