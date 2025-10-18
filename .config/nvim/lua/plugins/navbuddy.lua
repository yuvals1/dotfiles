return {
  'SmiteshP/nvim-navbuddy',
  keys = {
    {
      '<leader>oo',
      function()
        require('nvim-navbuddy').open()
      end,
      desc = 'Open Navbuddy',
    },
  },
  opts = {
    window = {
      border = 'single',
      size = { height = '20%', width = '100%' }, -- Set the size to 20% height and full width
      position = { row = '100%', col = '0%' }, -- Position at 80% from the top (bottom 20%)
      scrolloff = nil,
      sections = {
        left = {
          size = '20%',
          border = nil,
        },
        mid = {
          size = '40%',
          border = nil,
        },
        right = {
          border = nil,
          preview = 'leaf',
        },
      },
    },
    use_default_mappings = true,
    mappings = {},
    lsp = {
      auto_attach = true,
      preference = nil,
    },
    source_buffer = {
      follow_node = true,
      highlight = true,
      reorient = 'smart',
      scrolloff = nil,
    },
    custom_hl_group = nil,
  },
  dependencies = {
    'SmiteshP/nvim-navic',
    'MunifTanjim/nui.nvim',
    'numToStr/Comment.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
