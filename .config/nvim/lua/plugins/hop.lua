return {
  'smoka7/hop.nvim',
  event = 'BufReadPost', -- This will load the plugin when a buffer is read
  opts = {
    -- You can add any additional Hop options here
  },
  config = function(_, opts)
    -- This will be called after the plugin is loaded
    require('hop').setup(opts)

    -- Set up keymaps here
    vim.api.nvim_set_keymap('n', 'S', ':HopNodes<CR>', { noremap = true, silent = true, desc = 'Hop nodes' })
    vim.api.nvim_set_keymap('n', 'f', ':HopWord<CR>', { noremap = true, silent = true, desc = 'Hop word' })
    vim.api.nvim_set_keymap('n', 't', ':HopLine<CR>', { noremap = true, silent = true, desc = 'Hop line' })
    vim.api.nvim_set_keymap('n', 'T', ':HopLineStart<CR>', { noremap = true, silent = true, desc = 'Hop line start' })
  end,
}
