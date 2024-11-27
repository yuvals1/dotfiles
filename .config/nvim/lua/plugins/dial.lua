return {
  'monaqa/dial.nvim',
  keys = {
    '<C-a>',
    '<C-x>',
    { '<C-a>', mode = 'v' },
    { '<C-x>', mode = 'v' },
  },
  config = function()
    local augend = require 'dial.augend'

    -- Start with a minimal configuration to ensure everything works
    require('dial.config').augends:register_group {
      -- Default group that applies everywhere
      default = {
        -- Numbers
        augend.integer.alias.decimal, -- 1, 2, 3...
        augend.integer.alias.hex, -- 0x1, 0x2, 0x3...

        -- Dates
        augend.date.alias['%Y/%m/%d'], -- 2024/03/27
        augend.date.alias['%Y-%m-%d'], -- 2024-03-27

        -- Time
        augend.date.alias['%H:%M'], -- 23:59

        -- Boolean
        augend.constant.alias.bool, -- true/false

        -- Common operators
        augend.constant.new {
          elements = { '&&', '||' },
          word = false,
          cyclic = true,
        },
      },
    }

    -- Basic keymaps
    vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
    vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true })
    vim.keymap.set('v', '<C-a>', require('dial.map').inc_visual(), { noremap = true })
    vim.keymap.set('v', '<C-x>', require('dial.map').dec_visual(), { noremap = true })
  end,
}
