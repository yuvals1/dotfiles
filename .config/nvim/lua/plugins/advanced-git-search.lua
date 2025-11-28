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
