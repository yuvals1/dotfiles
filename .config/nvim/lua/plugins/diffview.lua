return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  config = function()
    require('diffview').setup {
      -- Default configuration will be used
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}
