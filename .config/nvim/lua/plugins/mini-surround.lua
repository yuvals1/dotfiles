return {
  'echasnovski/mini.surround',
  version = '*',
  config = function()
    -- Load the mini.surround module
    local mini_surround = require 'mini.surround'

    -- Set up the module with default or empty config
    mini_surround.setup {}

    -- Create a custom mapping for Visual mode using Lua function
    vim.keymap.set('x', 't', function()
      mini_surround.add 'visual'
    end, { noremap = true, silent = true })
  end,
}
