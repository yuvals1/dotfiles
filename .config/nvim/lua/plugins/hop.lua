return {
  'smoka7/hop.nvim',
  event = { 'BufReadPost', 'BufNewFile', 'VeryLazy' },
  opts = {
    -- You can add any additional Hop options here
  },
  config = function(_, opts)
    local hop = require 'hop'
    hop.setup(opts)

    -- Function to set keymap for both normal and visual modes
    local function map(modes, lhs, rhs, desc)
      vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    -- Set up keymaps for both normal and visual modes
    map({ 'n', 'v' }, 'S', function()
      hop.hint_nodes()
    end, 'Hop nodes')
    map({ 'n', 'v' }, 'f', function()
      hop.hint_words()
    end, 'Hop word')
    map({ 'n', 'v' }, 't', function()
      hop.hint_lines()
    end, 'Hop line')
    map({ 'n', 'v' }, 'T', function()
      hop.hint_lines_skip_whitespace()
    end, 'Hop line start')
  end,
}
