return {
  'aaronhallaert/advanced-git-search.nvim',
  cmd = { 'AdvancedGitSearch' },
  config = function()
    require('telescope').setup {
      extensions = {
        advanced_git_search = {
          diff_plugin = 'fugitive',
          git_flags = { '-c', 'delta.side-by-side=false' },
          git_diff_flags = {},
          show_builtin_git_pickers = false,
          entry_default_author_or_date = 'date', -- show date instead of author
        },
      },
    }
    require('telescope').load_extension 'advanced_git_search'

    -- The "Git actions" menu closes its picker and synchronously opens the
    -- selected one; telescope's deferred popup.move() then hits the dead
    -- window (plenary popup nvim_win_set_config error). Defer the handoff.
    local global_picker = require 'advanced_git_search.global_picker'
    local execute = global_picker.execute_git_function
    global_picker.execute_git_function = function(...)
      local args = { ... }
      vim.schedule(function()
        execute(unpack(args))
      end)
    end
  end,
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    -- Optionally, you can include diffview.nvim if you want to use it
    -- 'sindrets/diffview.nvim',
  },
  keys = {
    { '<leader>sg', '<cmd>AdvancedGitSearch<CR>', desc = 'Advanced Git Search' },
  },
}
