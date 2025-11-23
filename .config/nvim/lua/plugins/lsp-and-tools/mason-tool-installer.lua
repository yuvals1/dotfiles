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
      run_on_start = false, -- do not auto-install on startup to avoid repeated failures
    },
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)
      -- Use :MasonToolsInstall to install tools manually when needed.
      -- This avoids repeated installation failures on startup.
    end,
  }
end

return M
