local language_utils = require('plugins.languages.language_utils')
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'stevearc/conform.nvim',
    event = {"BufWritePre"},
    cmd = {"ConformInfo"},
    opts = {
      formatters_by_ft = configs.formatters,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  }
end

return M
