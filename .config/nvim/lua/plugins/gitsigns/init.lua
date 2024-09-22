-- File: lua/plugins/gitsigns/init.lua

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = require 'plugins.gitsigns.signs',
      on_attach = function(bufnr)
        require('plugins.gitsigns.keymaps').setup(bufnr)
      end,
    },
  },
}
