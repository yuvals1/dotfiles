local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>fc',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      formatters_by_ft = configs.formatters,
      formatters = configs.formatters_options, -- Ensure this line is active
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
    config = function(_, opts)
      local conform = require 'conform'
      -- Register custom formatter configurations
      for formatter_name, formatter_opts in pairs(opts.formatters) do
        conform.formatters[formatter_name] = formatter_opts
      end
      conform.setup(opts)
    end,
  }
end

return M
