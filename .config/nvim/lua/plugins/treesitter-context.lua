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
    max_lines = 0,
    line_numbers = true,
    multiline_threshold = 5,
    trim_scope = 'outer',
    mode = 'cursor',
    zindex = 20,
  },
}
