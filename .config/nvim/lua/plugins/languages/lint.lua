local language_utils = require('plugins.languages.language_utils')

local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)

  return {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = configs.linters
    end,
  }
end

return M
