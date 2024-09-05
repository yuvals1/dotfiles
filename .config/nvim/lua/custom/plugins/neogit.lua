-- File: ~/.config/nvim/lua/plugins/neogit.lua

return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    vim.keymap.set('n', '<leader>ng', function()
      local neogit = require 'neogit'
      neogit.open { cwd = vim.fn.expand '%:p:h' }
    end, { desc = "Neogit (current file's repo)" })
    local neogit = require 'neogit'
    neogit.setup {
      -- Disable hints
      disable_hint = false,
      -- Disable context highlighting
      disable_context_highlighting = false,
      -- Disable signs
      disable_signs = false,
      -- Disable commit message auto-insert
      disable_insert_on_commit = 'auto',
      -- Enable filewatcher
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      -- Set graph style
      graph_style = 'ascii',
      -- Integrate with Telescope
      integrations = {
        telescope = nil,
        diffview = nil,
        fzf_lua = nil,
      },
      -- Configure sections
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
        -- Add other sections as needed
      },
      -- Configure mappings
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
      -- Add other configurations as needed
    }
  end,
}
