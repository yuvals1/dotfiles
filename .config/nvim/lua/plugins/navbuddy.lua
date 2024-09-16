return {
  'SmiteshP/nvim-navbuddy',
  dependencies = {
    'neovim/nvim-lspconfig',
    'SmiteshP/nvim-navic',
    'MunifTanjim/nui.nvim',
    'numToStr/Comment.nvim', -- Optional
    'nvim-telescope/telescope.nvim', -- Optional
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
  config = function(_, opts)
    require('nvim-navbuddy').setup(opts)
    vim.keymap.set('n', '<leader>o', require('nvim-navbuddy').open, { desc = 'Open Navbuddy' })
  end,
}
