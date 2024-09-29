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
    },
  }
end

return M
