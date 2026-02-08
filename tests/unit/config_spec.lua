local config = require("visai.config")

describe("config", function()
  before_each(function()
    config.options = {}
  end)

  describe("setup", function()
    it("uses defaults when no options provided", function()
      config.setup()
      local opts = config.get()
      assert.are.equal("claude-code", opts.provider)
      assert.are.equal("ae", opts.keymap)
      assert.are.equal(300000, opts.timeout)
    end)

    it("merges user options with defaults", function()
      config.setup({ provider = "custom", keymap = "ce" })
      local opts = config.get()
      assert.are.equal("custom", opts.provider)
      assert.are.equal("ce", opts.keymap)
      assert.are.equal(300000, opts.timeout)
    end)

    it("deep merges nested options", function()
      config.setup({ window = { width = 80 } })
      local opts = config.get()
      assert.are.equal(80, opts.window.width)
      assert.are.equal(3, opts.window.height)
      assert.are.equal("rounded", opts.window.border)
    end)

    it("deep merges provider options", function()
      config.setup({
        providers = {
          ["claude-code"] = { args = { "-p" } },
        },
      })
      local opts = config.get()
      assert.are.equal("claude", opts.providers["claude-code"].cmd)
      assert.are.same({ "-p" }, opts.providers["claude-code"].args)
    end)

    it("adds new provider", function()
      config.setup({
        providers = {
          ["custom"] = { cmd = "custom-ai", args = {} },
        },
      })
      local opts = config.get()
      assert.are.equal("custom-ai", opts.providers["custom"].cmd)
      assert.is_not_nil(opts.providers["claude-code"])
    end)
  end)

  describe("get", function()
    it("returns empty table before setup", function()
      local opts = config.get()
      assert.are.same({}, opts)
    end)

    it("returns options after setup", function()
      config.setup()
      local opts = config.get()
      assert.is_not_nil(opts.provider)
    end)
  end)
end)
