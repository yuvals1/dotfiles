return {
  {
    'danielfalk/smart-open.nvim',
    branch = '0.2.x',
    event = 'VeryLazy',
    config = function()
      require('telescope').load_extension 'smart_open'

      -- Set up the mapping
      vim.keymap.set('n', '<leader>so', function()
        require('telescope').extensions.smart_open.smart_open()
      end, { noremap = true, silent = true, desc = 'Smart Open' })
    end,
    dependencies = {
      'kkharji/sqlite.lua',
      -- Only required if using match_algorithm fzf
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- Optional. If installed, native fzy will be used when match_algorithm is fzy
      { 'nvim-telescope/telescope-fzy-native.nvim' },
    },
  },
}
