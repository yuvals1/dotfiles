return {
  'supermaven-inc/supermaven-nvim',
  event = { 'InsertEnter', 'LspAttach' },
  config = function()
    require('supermaven-nvim').setup {
      keymaps = {
        accept_suggestion = '<C-e>',
        accept_word = '<C-d>',
        clear_suggestion = '<C-]>',
        -- We do NOT specify `accept_char` here because we'll define
        -- our own custom function for that next
      },
      log_level = 'info',
      disable_inline_completion = false,
    }

    -- Optional toggle, as in your example
    vim.keymap.set('n', '<leader>cc', ':SupermavenToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Supermaven' })

    ----------------------------------------------------------------
    -- 2. Add our custom “accept only the next character” mapping --
    ----------------------------------------------------------------
    vim.keymap.set('i', '<C-g>', function()
      -- The function we define below (see “Step 2”)
      require('user.supermaven_extra').accept_next_char()
    end, { noremap = true, silent = true })
  end,
}
