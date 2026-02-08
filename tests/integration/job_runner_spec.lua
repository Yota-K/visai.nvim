local runner = require("visai.job.runner")
local helpers = require("helpers")

describe("job.runner", function()
  after_each(function()
    runner.stop()
    runner.timed_out = false
    runner.active_job = nil
  end)

  describe("run", function()
    it("executes command and calls on_exit", function()
      local exit_called = false
      local exit_code = nil

      runner.run({ "echo", "hello" }, {
        on_exit = function(code, _)
          exit_called = true
          exit_code = code
        end,
      })

      helpers.wait_until(function()
        return exit_called
      end, 2000)

      assert.is_true(exit_called)
      assert.are.equal(0, exit_code)
    end)

    it("calls on_stdout with output chunks", function()
      local chunks = {}

      runner.run({ "echo", "hello" }, {
        on_stdout = function(chunk, _)
          table.insert(chunks, chunk)
        end,
      })

      helpers.wait_until(function()
        return #chunks > 0
      end, 2000)

      assert.is_true(#chunks > 0)
      local output = table.concat(chunks, "")
      assert.matches("hello", output)
    end)

    it("receives multiple chunks from multi-line output", function()
      local chunks = {}

      runner.run({ "sh", "-c", "echo line1; echo line2; echo line3" }, {
        on_stdout = function(chunk, _)
          table.insert(chunks, chunk)
        end,
      })

      helpers.wait_until(function()
        return #chunks >= 3
      end, 2000)

      local output = table.concat(chunks, "\n")
      assert.matches("line1", output)
      assert.matches("line2", output)
      assert.matches("line3", output)
    end)

    it("stops previous job when starting new one", function()
      local second_exit = false

      runner.run({ "sleep", "10" }, {})

      helpers.wait(50)

      runner.run({ "echo", "second" }, {
        on_exit = function()
          second_exit = true
        end,
      })

      helpers.wait_until(function()
        return second_exit
      end, 2000)

      assert.is_true(second_exit)
    end)
  end)

  describe("timeout", function()
    it("triggers on_error when job exceeds timeout", function()
      local error_called = false
      local error_msg = nil

      runner.run({ "sleep", "10" }, {
        timeout = 100,
        on_error = function(msg)
          error_called = true
          error_msg = msg
        end,
      })

      helpers.wait_until(function()
        return error_called
      end, 2000)

      assert.is_true(error_called)
      assert.matches("timed out", error_msg)
    end)

    it("includes timeout duration in error message", function()
      local error_msg = nil

      runner.run({ "sleep", "10" }, {
        timeout = 200,
        on_error = function(msg)
          error_msg = msg
        end,
      })

      helpers.wait_until(function()
        return error_msg ~= nil
      end, 2000)

      assert.matches("0.2s", error_msg)
    end)

    it("does not trigger on_error for fast commands", function()
      local error_called = false
      local exit_called = false

      runner.run({ "echo", "fast" }, {
        timeout = 5000,
        on_error = function()
          error_called = true
        end,
        on_exit = function()
          exit_called = true
        end,
      })

      helpers.wait_until(function()
        return exit_called
      end, 2000)

      assert.is_false(error_called)
      assert.is_true(exit_called)
    end)
  end)

  describe("stop", function()
    it("stops running job", function()
      runner.run({ "sleep", "10" }, {})

      helpers.wait(100)
      local was_running = runner.is_running()

      runner.stop()

      assert.is_true(was_running)
      assert.is_false(runner.is_running())
    end)

    it("handles stop when no job is running", function()
      assert.has_no.errors(function()
        runner.stop()
      end)
    end)
  end)

  describe("is_running", function()
    it("returns false when no job", function()
      assert.is_false(runner.is_running())
    end)

    it("returns false after job completes", function()
      local exit_called = false

      runner.run({ "echo", "done" }, {
        on_exit = function()
          exit_called = true
        end,
      })

      helpers.wait_until(function()
        return exit_called
      end, 2000)

      helpers.wait(100)
      assert.is_false(runner.is_running())
    end)
  end)

  describe("streaming behavior", function()
    it("receives output before job completes", function()
      local stdout_received = false
      local exit_called = false

      runner.run({ "sh", "-c", "echo first; sleep 0.5; echo second" }, {
        on_stdout = function(chunk, _)
          if chunk == "first" and not exit_called then
            stdout_received = true
          end
        end,
        on_exit = function()
          exit_called = true
        end,
      })

      helpers.wait_until(function()
        return stdout_received
      end, 2000)

      assert.is_true(stdout_received)

      helpers.wait_until(function()
        return exit_called
      end, 2000)
    end)
  end)
end)
