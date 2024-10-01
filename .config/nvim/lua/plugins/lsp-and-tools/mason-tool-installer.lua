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
      run_on_start = false, -- We'll handle this manually
    },
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)

      -- Create a custom event for cleaning
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MasonToolsCleanupEvent',
        callback = function()
          vim.cmd 'MasonToolsUpdate'
          vim.cmd 'MasonToolsClean'
          -- print 'MasonToolsClean has been run automatically'
        end,
      })

      -- Trigger the cleanup event after a delay
      vim.defer_fn(function()
        vim.cmd 'doautocmd User MasonToolsCleanupEvent'
      end, 5000) -- 5 second delay
    end,
  }
end

return M
