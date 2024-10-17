return {
  'echasnovski/mini.surround',
  version = '*',
  config = function()
    -- Load the mini.surround module
    local mini_surround = require 'mini.surround'

    vim.keymap.set('x', 't', function()
      mini_surround.add 'visual'
    end, { noremap = true, silent = true })
  end,
}
