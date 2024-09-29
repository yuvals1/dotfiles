local language_utils = require('plugins.languages.language_utils')
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'williamboman/mason.nvim',
    cmd = "Mason",
    event = "VeryLazy",
    opts = {
      ensure_installed = configs.mason_packages,
    },
  }
end

return M
