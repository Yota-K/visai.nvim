local updater = require("visai.buffer.updater")

describe("buffer_updater", function()
  describe("parse_lines", function()
    it("returns empty table for nil", function()
      local result = updater.parse_lines(nil)
      assert.are.same({}, result)
    end)

    it("returns empty table for empty string", function()
      local result = updater.parse_lines("")
      assert.are.same({}, result)
    end)

    it("parses single line", function()
      local result = updater.parse_lines("hello")
      assert.are.same({ "hello" }, result)
    end)

    it("parses multiple lines", function()
      local result = updater.parse_lines("hello\nworld")
      assert.are.same({ "hello", "world" }, result)
    end)

    it("removes trailing empty lines", function()
      local result = updater.parse_lines("hello\nworld\n\n\n")
      assert.are.same({ "hello", "world" }, result)
    end)

    it("preserves internal empty lines", function()
      local result = updater.parse_lines("hello\n\nworld")
      assert.are.same({ "hello", "", "world" }, result)
    end)

    it("handles text with only newlines", function()
      local result = updater.parse_lines("\n\n\n")
      assert.are.same({}, result)
    end)
  end)

  describe("apply_indent", function()
    it("returns lines unchanged when indent is 0", function()
      local lines = { "hello", "world" }
      local result = updater.apply_indent(lines, 0)
      assert.are.same({ "hello", "world" }, result)
    end)

    it("returns lines unchanged when indent is negative", function()
      local lines = { "hello", "world" }
      local result = updater.apply_indent(lines, -2)
      assert.are.same({ "hello", "world" }, result)
    end)

    it("adds 2-space indent to each line", function()
      local lines = { "hello", "world" }
      local result = updater.apply_indent(lines, 2)
      assert.are.same({ "  hello", "  world" }, result)
    end)

    it("adds 4-space indent to each line", function()
      local lines = { "hello", "world" }
      local result = updater.apply_indent(lines, 4)
      assert.are.same({ "    hello", "    world" }, result)
    end)

    it("does not add indent to empty lines", function()
      local lines = { "hello", "", "world" }
      local result = updater.apply_indent(lines, 4)
      assert.are.same({ "    hello", "", "    world" }, result)
    end)

    it("preserves existing indentation", function()
      local lines = { "hello", "  nested" }
      local result = updater.apply_indent(lines, 2)
      assert.are.same({ "  hello", "    nested" }, result)
    end)
  end)
end)
