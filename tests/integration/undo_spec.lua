local updater = require("visai.buffer.updater")
local helpers = require("helpers")

describe("buffer_updater undo integration", function()
  local bufnr

  before_each(function()
    bufnr = helpers.create_buffer({ "line1", "line2", "line3" })
    vim.api.nvim_set_current_buf(bufnr)
    updater.state = nil
  end)

  after_each(function()
    updater.state = nil
    helpers.delete_buffer(bufnr)
  end)

  describe("update", function()
    it("sets first_update to false after first update", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      assert.is_true(updater.state.first_update)

      updater.update("new content")
      helpers.wait(50)

      assert.is_false(updater.state.first_update)
    end)

    it("first_update remains false on subsequent updates", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      updater.update("first")
      helpers.wait(50)
      assert.is_false(updater.state.first_update)

      updater.update("second")
      helpers.wait(50)
      assert.is_false(updater.state.first_update)
    end)
  end)

  describe("finish", function()
    it("clears state after finish", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      updater.finish("done")
      helpers.wait(50)

      assert.is_nil(updater.state)
    end)

    it("updates buffer with final content", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      updater.finish("final line")
      helpers.wait(50)

      local lines = helpers.get_buffer_lines(bufnr)
      assert.are.same({ "final line" }, lines)
    end)
  end)

  describe("cancel", function()
    it("restores original lines on cancel", function()
      local original = { "line1", "line2", "line3" }
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = original,
        indent = 0,
      })

      updater.update("modified content")
      helpers.wait(50)

      updater.cancel()
      helpers.wait(50)

      local lines = helpers.get_buffer_lines(bufnr)
      assert.are.same(original, lines)
    end)

    it("clears state after cancel", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      updater.cancel()
      helpers.wait(50)

      assert.is_nil(updater.state)
    end)
  end)

  describe("buffer updates", function()
    it("replaces lines in buffer", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 0,
      })

      updater.update("new line 1\nnew line 2")
      helpers.wait(50)

      local lines = helpers.get_buffer_lines(bufnr)
      assert.are.same({ "new line 1", "new line 2" }, lines)
    end)

    it("applies indent to new content", function()
      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 3,
        lines = { "line1", "line2", "line3" },
        indent = 4,
      })

      updater.update("new content")
      helpers.wait(50)

      local lines = helpers.get_buffer_lines(bufnr)
      assert.are.same({ "    new content" }, lines)
    end)

    it("handles multi-line content with indent", function()
      bufnr = helpers.create_buffer({ "  line1", "  line2" })
      vim.api.nvim_set_current_buf(bufnr)

      updater.start({
        bufnr = bufnr,
        start_line = 1,
        end_line = 2,
        lines = { "  line1", "  line2" },
        indent = 2,
      })

      updater.update("first\nsecond\nthird")
      helpers.wait(50)

      local lines = helpers.get_buffer_lines(bufnr)
      assert.are.same({ "  first", "  second", "  third" }, lines)
    end)
  end)
end)
