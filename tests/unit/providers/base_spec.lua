local base = require("visai.providers.base")

describe("providers.base", function()
  describe("new", function()
    it("creates provider with name and cmd", function()
      local provider = base.new({ name = "test", cmd = "test-cmd" })
      assert.are.equal("test", provider.name)
      assert.are.equal("test-cmd", provider.cmd)
    end)

    it("initializes args to empty table by default", function()
      local provider = base.new({ name = "test", cmd = "test-cmd" })
      assert.are.same({}, provider.args)
    end)

    it("accepts custom args", function()
      local provider = base.new({ name = "test", cmd = "test-cmd", args = { "-a", "-b" } })
      assert.are.same({ "-a", "-b" }, provider.args)
    end)
  end)

  describe("is_available", function()
    it("returns true for existing command", function()
      local provider = base.new({ name = "test", cmd = "echo" })
      assert.is_true(provider:is_available())
    end)

    it("returns false for non-existing command", function()
      local provider = base.new({ name = "test", cmd = "nonexistent_command_xyz" })
      assert.is_false(provider:is_available())
    end)
  end)

  describe("build_prompt", function()
    it("formats prompt with instruction and code", function()
      local provider = base.new({ name = "test", cmd = "test-cmd" })
      local prompt = provider:build_prompt("function foo() end", "Add a comment")
      assert.matches("Add a comment", prompt)
      assert.matches("function foo%(%) end", prompt)
    end)
  end)

  describe("build_cmd", function()
    it("raises error when not implemented", function()
      local provider = base.new({ name = "test", cmd = "test-cmd" })
      assert.has_error(function()
        provider:build_cmd("test prompt")
      end, "build_cmd must be implemented")
    end)

    it("uses custom implementation when provided", function()
      local provider = base.new({
        name = "test",
        cmd = "test-cmd",
        build_cmd = function(self, prompt)
          return { self.cmd, prompt }
        end,
      })
      local result = provider:build_cmd("hello")
      assert.are.same({ "test-cmd", "hello" }, result)
    end)
  end)

  describe("parse_output", function()
    it("returns text unchanged by default", function()
      local provider = base.new({ name = "test", cmd = "test-cmd" })
      local result = provider:parse_output("hello world")
      assert.are.equal("hello world", result)
    end)

    it("uses custom implementation when provided", function()
      local provider = base.new({
        name = "test",
        cmd = "test-cmd",
        parse_output = function(self, text)
          return text:upper()
        end,
      })
      local result = provider:parse_output("hello")
      assert.are.equal("HELLO", result)
    end)
  end)
end)
