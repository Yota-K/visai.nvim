local M = {}

local providers = {}

local provider_modules = {
  ["claude-code"] = "visai.providers.claude-code",
}

function M.get(name)
  if providers[name] then
    return providers[name]
  end

  local module_path = provider_modules[name]
  if not module_path then
    return nil
  end

  local ok, provider = pcall(require, module_path)
  if ok then
    providers[name] = provider
    return provider
  end

  return nil
end

function M.list()
  return vim.tbl_keys(provider_modules)
end

function M.register(name, provider)
  provider_modules[name] = nil
  providers[name] = provider
end

return M
