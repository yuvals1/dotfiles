-- nvim v0.8.0
return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    { '<leader>lc', '<cmd>LazyGitConfig<cr>', desc = 'LazyGitConfig' },
    { '<leader>lf', '<cmd>LazyGitFilterCurrentFile<cr>', desc = 'LazyGitFilterCurrentFile' },
  },
  config = function()
    vim.g.lazygit_use_custom_config_file_path = 1
    vim.g.lazygit_config_file_path = '~/.config/lazygit/config.yml'
  end,
}
