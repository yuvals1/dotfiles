-- mason-tool-installer.lua
local language_utils = require 'plugins.languages.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = configs.tools,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000, -- 3-second delay
    },
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)

      -- Set up autocmd to run MasonToolsClean on startup
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          vim.schedule(function()
            vim.cmd 'MasonToolsClean'
            print 'MasonToolsClean has been run automatically'
          end)
        end,
      })
    end,
  }
end

return M
