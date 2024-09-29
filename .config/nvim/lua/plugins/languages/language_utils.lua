local M = {}

function M.collect_configurations(languages)
  local configs = {
    mason_packages = {},
    lsp_servers = {},
    formatters = {},
    linters = {}
  }

  for _, lang in ipairs(languages) do
    -- Collect Mason packages
    if lang.mason then
      vim.list_extend(configs.mason_packages, lang.mason)
    end
    
    -- Collect LSP servers
    if lang.lsp then
      for server, config in pairs(lang.lsp) do
        configs.lsp_servers[server] = config
      end
    end
    
    -- Collect formatters
    if lang.formatters then
      for ft, formatter in pairs(lang.formatters) do
        configs.formatters[ft] = formatter
      end
    end
    
    -- Collect linters
    if lang.linters then
      for ft, linter in pairs(lang.linters) do
        configs.linters[ft] = linter
      end
    end
  end

  return configs
end

return M
