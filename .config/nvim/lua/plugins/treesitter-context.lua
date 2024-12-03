return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  event = 'VeryLazy',
  keys = {
    { '<leader>tc', '<cmd>TSContextToggle<CR>', desc = 'Toggle Treesitter Context' },
  },
  opts = {
    enable = true,
    max_lines = 3, -- Reduced from 5
    line_numbers = true,
    multiline_threshold = 3, -- Reduced from 5
    trim_scope = 'inner', -- Changed from 'outer'
    mode = 'cursor',
    zindex = 20,
  },
  config = function()
    -- Set up custom highlights for the context window
    vim.api.nvim_set_hl(0, 'TreesitterContext', { bg = '#4c313c' }) -- Background color
    vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', { fg = '#7c8494' }) -- Line number color
    -- Optional: Add a subtle bottom border
    vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { sp = '#3e4451', underline = true })
  end,
}
