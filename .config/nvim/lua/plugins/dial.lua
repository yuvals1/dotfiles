-- File: ~/.config/nvim/lua/plugins/dial.lua

return {
  'monaqa/dial.nvim',
  -- Plugin can be loaded when these keys are pressed in normal or visual mode
  keys = {
    '<C-a>',
    '<C-x>',
    'g<C-a>',
    'g<C-x>',
    { '<C-a>', mode = 'v' },
    { '<C-x>', mode = 'v' },
    { 'g<C-a>', mode = 'v' },
    { 'g<C-x>', mode = 'v' },
  },
  config = function()
    local augend = require 'dial.augend'

    -- Configure different augend groups for different contexts
    require('dial.config').augends:register_group {
      -- Default group that applies everywhere
      default = {
        augend.integer.alias.decimal, -- Matches decimal integers (0-9)
        augend.integer.alias.hex, -- Matches hex integers (0x0-0xf)
        augend.date.alias['%Y/%m/%d'], -- Matches dates (2024/03/27)
        augend.constant.alias.bool, -- Matches true/false
        augend.semver.alias.semver, -- Matches semantic versions (1.0.0)

        -- Custom ordered constants
        augend.constant.new {
          elements = { 'and', 'or' },
          word = true, -- Match only at word boundaries
          cyclic = true, -- Cycle back to first element after last
        },
        augend.constant.new {
          elements = { '&&', '||' },
          word = false, -- Match anywhere
          cyclic = true,
        },
      },

      -- Visual mode-specific group with additional text manipulations
      visual = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
        augend.constant.alias.alpha, -- Single lowercase letters (a-z)
        augend.constant.alias.Alpha, -- Single uppercase letters (A-Z)
      },

      -- TypeScript/JavaScript specific group
      typescript = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        -- Toggle between let/const
        augend.constant.new {
          elements = { 'let', 'const' },
          word = true,
          cyclic = true,
        },
        -- Toggle between common types
        augend.constant.new {
          elements = { 'string', 'number', 'boolean', 'any' },
          word = true,
          cyclic = true,
        },
      },
    }

    -- Set up keymaps for normal mode
    vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
    vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true })
    vim.keymap.set('n', 'g<C-a>', require('dial.map').inc_gnormal(), { noremap = true })
    vim.keymap.set('n', 'g<C-x>', require('dial.map').dec_gnormal(), { noremap = true })

    -- Set up keymaps for visual mode
    vim.keymap.set('v', '<C-a>', require('dial.map').inc_visual 'visual', { noremap = true })
    vim.keymap.set('v', '<C-x>', require('dial.map').dec_visual 'visual', { noremap = true })
    vim.keymap.set('v', 'g<C-a>', require('dial.map').inc_gvisual 'visual', { noremap = true })
    vim.keymap.set('v', 'g<C-x>', require('dial.map').dec_gvisual 'visual', { noremap = true })

    -- Set up FileType specific mappings
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
      callback = function()
        -- Use typescript group for TS/JS files
        vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal 'typescript', { buffer = true })
        vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal 'typescript', { buffer = true })
      end,
    })
  end,
}
