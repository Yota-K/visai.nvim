local plenary_path = vim.fn.stdpath("data") .. "/site/pack/vendor/start/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 0 then
  plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
end
vim.opt.runtimepath:append(plenary_path)

local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:append(plugin_path)

package.path = plugin_path .. "/tests/?.lua;" .. plugin_path .. "/tests/?/init.lua;" .. package.path

vim.cmd([[runtime plugin/plenary.vim]])
