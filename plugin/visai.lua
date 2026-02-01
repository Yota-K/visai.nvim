if vim.g.loaded_visai then
  return
end
vim.g.loaded_visai = true

vim.api.nvim_create_user_command("AIEditSetup", function()
  require("visai").setup()
end, {})

vim.api.nvim_create_user_command("AIEditCancel", function()
  require("visai").cancel()
end, {})
