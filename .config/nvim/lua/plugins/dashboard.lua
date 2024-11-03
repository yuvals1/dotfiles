return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'hyper',
      config = {
        project = {
          enable = false, -- Temporarily disable project feature
          limit = 8,
          icon = ' ',
          label = '',
          action = function()
            require('telescope.builtin').find_files()
          end,
        },
        shortcut = {
          {
            desc = 'Files',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f',
          },
        },
        footer = {}, -- Empty footer
      },
    }
  end,
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      lazy = true,
    },
  },
}
