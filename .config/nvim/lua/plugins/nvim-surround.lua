return {
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    keys = {
      { 'S', '<Plug>(nvim-surround-visual)', mode = 'x' },
    },
    config = function()
      require('nvim-surround').setup {}
    end,
  },
}
