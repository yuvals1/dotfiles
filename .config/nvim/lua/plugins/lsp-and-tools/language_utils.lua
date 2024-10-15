-- language_utils.lua
local M = {}

function M.collect_configurations(languages)
  local configs = {
    lsp_servers = {},
    formatters = {},
    formatters_options = {},

    linters = {},
    linter_options = {},
    tools = {},
  }

  for _, lang in ipairs(languages) do
    -- Collect Mason package names (tools)
    if lang.mason then
      vim.list_extend(configs.tools, lang.mason)
    end

    -- Collect LSP servers
    if lang.lsp then
      for server, config in pairs(lang.lsp) do
        configs.lsp_servers[server] = config
      end
    end

    -- Collect formatters
    if lang.formatters then
      for ft, formatters in pairs(lang.formatters) do
        configs.formatters[ft] = formatters
      end
    end

    -- Collect formatter options
    if lang.formatter_options then
      for formatter, options in pairs(lang.formatter_options) do
        configs.formatters_options[formatter] = options
      end
    end

    -- Collect linters
    if lang.linters then
      for ft, linters in pairs(lang.linters) do
        configs.linters[ft] = linters
      end
    end

    -- Collect linter options
    if lang.linter_options then
      for linter, options in pairs(lang.linter_options) do
        configs.linter_options[linter] = options
      end
    end
  end

  -- Remove duplicates from tools
  configs.tools = vim.fn.uniq(configs.tools)

  return configs
end

return M
