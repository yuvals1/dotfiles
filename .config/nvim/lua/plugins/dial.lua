-- File: ~/.config/nvim/lua/plugins/dial.lua

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

    require('dial.config').augends:register_group {
      -- Default group that applies everywhere
      default = {
        -- Number augends
        augend.integer.alias.decimal, -- Regular numbers (0-9)
        augend.integer.alias.hex, -- Hex numbers (0x1, 0xff)
        augend.integer.alias.binary, -- Binary numbers (0b0101)

        -- Date and time augends
        augend.date.alias['%Y/%m/%d'], -- 2024/03/27
        augend.date.alias['%Y-%m-%d'], -- 2024-03-27
        augend.date.alias['%H:%M'], -- 23:59

        -- Programming augends
        augend.constant.alias.bool, -- true/false
        augend.constant.new {
          elements = { '&&', '||' },
          word = false,
          cyclic = true,
        },

        -- Add semantic versioning support
        augend.semver.alias.semver, -- Increment version numbers (1.2.3)

        -- Add hex color support
        augend.hexcolor.new { case = 'lower' }, -- Color codes (#fff, #abcdef)
      },

      -- Special group for visual mode
      visual = {
        -- Include everything from default group
        augend.integer.alias.decimal,
        augend.integer.alias.hex,

        -- Add letter sequences for visual mode
        augend.constant.alias.alpha, -- Lowercase letters (a-z)
        augend.constant.alias.Alpha, -- Uppercase letters (A-Z)
      },
    }

    -- Regular increment/decrement
    vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
    vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true })

    -- Visual mode with special group
    vim.keymap.set('v', '<C-a>', require('dial.map').inc_visual 'visual', { noremap = true })
    vim.keymap.set('v', '<C-x>', require('dial.map').dec_visual 'visual', { noremap = true })
  end,
}
