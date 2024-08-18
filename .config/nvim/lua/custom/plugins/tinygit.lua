return {
  'chrisgrieser/nvim-tinygit',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-telescope/telescope.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    local tinygit = require 'tinygit'

    -- Setup (customize as needed)
    tinygit.setup {
      historySearch = {
        diffPopup = {
          width = 0.8,
          height = 0.8,
          border = 'single',
        },
      },
    }

    -- Key mappings for important commands
    vim.keymap.set('n', '<leader>gs', tinygit.interactiveStaging, { desc = 'TinyGit: Interactive Staging' })
    vim.keymap.set('n', '<leader>gc', tinygit.smartCommit, { desc = 'TinyGit: Smart Commit' })
    vim.keymap.set('n', '<leader>gp', tinygit.push, { desc = 'TinyGit: Push' })
    vim.keymap.set('n', '<leader>gf', tinygit.searchFileHistory, { desc = 'TinyGit: Search File History' })
    vim.keymap.set('n', '<leader>gl', tinygit.lineHistory, { desc = 'TinyGit: Line History' })
    vim.keymap.set('n', '<leader>gF', tinygit.functionHistory, { desc = 'TinyGit: Function History' })
    vim.keymap.set('n', '<leader>ga', tinygit.amendNoEdit, { desc = 'TinyGit: Amend (No Edit)' })
    vim.keymap.set('n', '<leader>gA', tinygit.amendOnlyMsg, { desc = 'TinyGit: Amend (Only Message)' })
    vim.keymap.set('n', '<leader>gx', tinygit.fixupCommit, { desc = 'TinyGit: Fixup Commit' })
  end,
}
