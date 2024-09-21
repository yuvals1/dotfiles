return {
  'aaronhallaert/advanced-git-search.nvim',
  cmd = { 'AdvancedGitSearch' },
  config = function()
    require('telescope').setup {
      extensions = {
        advanced_git_search = {
          -- See Config
        },
      },
    }
    require('telescope').load_extension 'advanced_git_search'
  end,
  dependencies = {
    --- See dependencies
  },
  keys = {
    { '<leader>sg', '<cmd>AdvancedGitSearch<CR>', desc = 'Advanced Git Search' },
  },
}
