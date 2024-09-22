return {
  {
    'jellydn/hurl.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = 'hurl',
    opts = {
      -- Show debugging info
      debug = false,
      -- Show notification on run
      show_notification = false,
      -- Show response in popup or split
      mode = 'split',
      -- Default formatter
      formatters = {
        json = { 'jq' },
        html = {
          'prettier',
          '--parser',
          'html',
        },
        xml = {
          'tidy',
          '-xml',
          '-i',
          '-q',
        },
      },
      -- Default mappings for the response popup or split views
      mappings = {
        close = 'q',
        next_panel = '<C-n>',
        prev_panel = '<C-p>',
      },
      -- Set the environment file to ../.yuval.env
      env_file = { '../.yuval.env' },
    },
    keys = {
      {
        '<leader>A',
        function()
          vim.cmd 'HurlRunnerAt --file-root /Users/yuvals1/data'
        end,
        desc = 'Run Api request',
      },
      {
        '<leader>a',
        function()
          vim.cmd 'HurlRunner --file-root /Users/yuvals1/data'
        end,
        desc = 'Run All requests',
      },
      { '<leader>te', '<cmd>HurlRunnerToEntry<CR>', desc = 'Run Api request to entry' },
      { '<leader>tm', '<cmd>HurlToggleMode<CR>', desc = 'Hurl Toggle Mode' },
      { '<leader>tv', '<cmd>HurlVerbose<CR>', desc = 'Run Api in verbose mode' },
      { '<leader>h', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
    },
  },
}
