local language_utils = require 'plugins.languages.language_utils'
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
      -- formatters = configs.formatters_options, -- Added this line
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  }
end

return M
