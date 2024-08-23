return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  build = 'make',
  opts = {
    provider = 'claude',
    claude = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-3-5-sonnet-20240620',
      temperature = 0,
      max_tokens = 4096,
    },
    mappings = {
      ask = '<leader>aa',
      edit = '<leader>ae',
      refresh = '<leader>ar',
      diff = {
        ours = 'co',
        theirs = 'ct',
        none = 'c0',
        both = 'cb',
        next = ']x',
        prev = '[x',
      },
      jump = {
        next = ']]',
        prev = '[[',
      },
    },
    hints = { enabled = true },
    windows = {
      wrap_line = true,
      width = 30,
    },
    highlights = {
      diff = {
        current = 'DiffText',
        incoming = 'DiffAdd',
      },
    },
    diff = {
      debug = false,
      autojump = true,
      list_opener = 'copen',
    },
  },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    {
      'grapp-dev/nui-components.nvim',
      dependencies = {
        'MunifTanjim/nui.nvim',
      },
    },
    --- The below is optional, make sure to setup it properly if you have lazy=true
    -- {
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   opts = {
    --     file_types = { 'markdown', 'Avante' },
    --   },
    --   ft = { 'markdown', 'Avante' },
    -- },
  },
}
