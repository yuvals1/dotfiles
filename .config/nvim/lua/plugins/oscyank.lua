return {
  {
    'ojroques/vim-oscyank',
    branch = 'main',
    config = function()
      -- Configure vim-oscyank
      vim.g.oscyank_max_length = 0 -- maximum length of a selection (0 means no limit)
      vim.g.oscyank_silent = false -- set to true to disable message on successful copy
      vim.g.oscyank_trim = false -- set to true to trim surrounding whitespaces before copy

      -- Set up keymaps
      vim.keymap.set('n', '<leader>c', '<Plug>OSCYankOperator', { desc = 'OSC Yank Operator' })
      vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true, desc = 'OSC Yank Line' })
      vim.keymap.set('v', '<leader>c', '<Plug>OSCYankVisual', { desc = 'OSC Yank Visual' })

      -- Set up autocmd for automatic copying (optional)
      vim.api.nvim_create_autocmd('TextYankPost', {
        callback = function()
          if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
            vim.fn['OSCYankRegister'] '"'
          end
        end,
      })
    end,
  },
}
