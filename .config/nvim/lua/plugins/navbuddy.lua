return {
  'SmiteshP/nvim-navbuddy',
  keys = {
    {
      '<leader>o',
      function()
        require('nvim-navbuddy').open()
      end,
      desc = 'Open Navbuddy',
    },
  },
  opts = {
    window = {
      border = 'single',
      size = '60%',
      position = '50%',
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
    'neovim/nvim-lspconfig',
    'SmiteshP/nvim-navic',
    'MunifTanjim/nui.nvim',
    'numToStr/Comment.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
