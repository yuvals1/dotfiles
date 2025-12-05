-- mason-tool-installer.lua
local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    -- Load on startup so run_on_start actually works on new machines
    lazy = false,
    opts = {
      ensure_installed = configs.tools,
      auto_update = false,
      run_on_start = true,
    },
  }
end

return M
