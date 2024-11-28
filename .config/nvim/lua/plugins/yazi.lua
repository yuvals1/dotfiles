return {
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    config = function()
      require('yazi').setup {
        open_for_directories = false,
        -- Enable these if you are using the latest version of yazi
        -- use_ya_for_events_reading = true,
        -- use_yazi_client_id_flag = true,
        keymaps = {
          show_help = '<f1>',
        },
      }
      -- Resume the last yazi session
      vim.keymap.set('n', '-', '<CMD>Yazi toggle<CR>', { desc = 'Resume last yazi session' })

      -- Open yazi at the current file
      vim.keymap.set('n', '<leader>-', '<CMD>Yazi<CR>', { desc = 'Open yazi at the current file' })

      -- Open the file manager in nvim's working directory
      vim.keymap.set('n', '<leader>=', '<CMD>Yazi cwd<CR>', { desc = 'Open yazi in working directory' })
    end,
  },
}
