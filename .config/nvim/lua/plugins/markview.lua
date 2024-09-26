return {
  'OXY2DEV/markview.nvim',
  lazy = true, -- Recommended to not lazy-load this plugin
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('markview').setup {
      -- Your configuration options here
      -- For example:
      modes = { 'n', 'no', 'c' },
      hybrid_modes = { 'n' },
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = 'c'
        end,
      },
    }

    -- Optionally, you can enable Markview for all buffers here
    -- vim.cmd("Markview enableAll")
  end,
}
