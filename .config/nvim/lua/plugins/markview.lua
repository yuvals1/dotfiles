return {
  'OXY2DEV/markview.nvim',
  ft = 'markdown', -- Load only for Markdown files
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
    -- Optionally, you can enable Markview for all Markdown buffers here
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        vim.cmd 'Markview enable'
      end,
    })
  end,
}
