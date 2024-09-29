local M = {}

function M.setup(languages)
  return {
    'williamboman/mason.nvim',
    -- Remove the 'event' and 'cmd' options to load at startup
    opts = {},
  }
end

return M
