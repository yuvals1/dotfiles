-- language_utils.lua
local M = {}

local function dedup_preserve_order(list)
  local out, seen = {}, {}
  for _, item in ipairs(list or {}) do
    if not seen[item] then
      table.insert(out, item)
      seen[item] = true
    end
  end
  return out
end

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

  -- Remove duplicates from tools (order-preserving)
  configs.tools = dedup_preserve_order(configs.tools)

  -- Apply platform-specific overrides (e.g., skip unsupported servers/tools)
  local ok, platform = pcall(require, 'plugins.lsp-and-tools.platform')
  if ok and platform and type(platform.apply_overrides) == 'function' then
    configs = platform.apply_overrides(configs)
  end

  return configs
end

return M
