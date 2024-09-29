-- mason-tool-installer.lua
local language_utils = require 'plugins.languages.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' }, -- Ensure mason.nvim loads first
    -- Remove 'cmd' and 'event' to load at startup
    opts = {
      ensure_installed = configs.tools,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000, -- 3-second delay
      debounce_hours = 5, -- Optional: Prevent frequent reinstalls
    },
  }
end

return M
