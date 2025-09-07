-- mason-tool-installer.lua
local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate', 'MasonToolsClean' },
    opts = {
      ensure_installed = configs.tools,
      auto_update = false,
      run_on_start = false, -- do not auto-install on startup
    },
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)
      -- No automatic update/clean on startup to avoid noisy failures on
      -- unsupported platforms or missing toolchains. Use the commands
      -- :MasonToolsInstall, :MasonToolsUpdate, :MasonToolsClean manually.
    end,
  }
end

return M
