return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  build = 'make',
  opts = {
    -- add any opts here
    debug = true,
    provider = 'claude',
  },
  config = function(_, opts)
    print('Avante config function called with opts:', vim.inspect(opts))
    local avante = require 'avante'
    avante.setup(opts)
    print('Avante setup called. did_setup =', avante.did_setup)
    print('Avante options after setup:', vim.inspect(avante.options))
  end,
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
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
