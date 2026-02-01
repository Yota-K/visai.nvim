# visai.nvim

A minimal Neovim plugin to edit visually selected code with AI.

**Zero dependencies** - uses only Neovim built-in APIs.

## Features

- Edit visually selected code with AI assistance
- Real-time streaming updates to buffer
- Support for Claude Code CLI
- Simple floating window UI for entering instructions
- Preserves original indentation

## Requirements

- Neovim >= 0.9.0
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Yota-K/visai.nvim",
  config = function()
    require("visai").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "Yota-K/visai.nvim",
  config = function()
    require("visai").setup()
  end,
}
```

## Usage

1. Select code in visual mode (`v`, `V`, or `<C-v>`)
2. Press `ae` (default keymap)
3. Enter your instruction (e.g., "add error handling", "translate to Japanese")
4. Press `<C-s>` to execute or `<Esc>` to cancel
5. Press `q` or `<Esc>` to close the progress window when complete

## Keymaps

| Mode | Key | Action |
|------|-----|--------|
| Visual | `ae` | Open instruction window |
| Insert/Normal (in instruction window) | `<C-s>` | Execute |
| Normal (in instruction window) | `<Esc>`, `q` | Cancel |
| Normal (in progress window) | `<Esc>`, `q` | Close |

## Configuration

```lua
require("visai").setup({
  -- AI provider
  provider = "claude-code",

  -- Keymap to trigger (set to nil to disable)
  keymap = "ae",

  -- Timeout in milliseconds (5 minutes default)
  timeout = 300000,

  -- Floating window settings
  window = {
    width = 60,
    height = 3,
    border = "rounded",
    title = " Visai ",
  },
})
```

## Commands

- `:Visai` - Edit selected block (use after visual selection)
- `:VisaiCancel` - Cancel running AI process

## License

MIT
