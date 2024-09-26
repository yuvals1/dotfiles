-- .config/nvim/lua/plugins/neogit.lua
return {
  'NeogitOrg/neogit',
  cmd = 'Neogit',
  keys = {
    {
      '<leader>ng',
      function()
        require('neogit').open { cwd = vim.fn.expand '%:p:h' }
      end,
      desc = "Neogit (current file's repo)",
    },
  },
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'sindrets/diffview.nvim', lazy = true },
    { 'nvim-telescope/telescope.nvim', lazy = true },
  },
  config = function()
    local neogit = require 'neogit'
    neogit.setup {
      disable_hint = false,
      disable_context_highlighting = false,
      disable_signs = false,
      disable_insert_on_commit = 'auto',
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      graph_style = 'ascii',
      integrations = {
        telescope = nil,
        diffview = nil,
        fzf_lua = nil,
      },
      sections = {
        untracked = {
          folded = false,
          hidden = false,
        },
        unstaged = {
          folded = false,
          hidden = false,
        },
        staged = {
          folded = false,
          hidden = false,
        },
      },
      mappings = {
        status = {
          ['q'] = 'Close',
          ['1'] = 'Depth1',
          ['2'] = 'Depth2',
          ['3'] = 'Depth3',
          ['4'] = 'Depth4',
          ['<tab>'] = 'Toggle',
          ['x'] = 'Discard',
          ['s'] = 'Stage',
          ['S'] = 'StageUnstaged',
          ['<c-s>'] = 'StageAll',
          ['u'] = 'Unstage',
          ['U'] = 'UnstageStaged',
          ['$'] = 'CommandHistory',
          ['<c-r>'] = 'RefreshBuffer',
          ['<enter>'] = 'GoToFile',
          ['<c-v>'] = 'VSplitOpen',
          ['<c-x>'] = 'SplitOpen',
          ['<c-t>'] = 'TabOpen',
          ['{'] = 'GoToPreviousHunkHeader',
          ['}'] = 'GoToNextHunkHeader',
        },
      },
    }
  end,
}
