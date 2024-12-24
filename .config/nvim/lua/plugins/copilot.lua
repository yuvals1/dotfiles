return {
  'zbirenbaum/copilot.lua',
  -- Change from just InsertEnter to include VimEnter
  event = { 'VimEnter', 'InsertEnter' },
  config = function()
    require('copilot').setup {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<C-d>',
          accept_word = '<C-e>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      filetypes = {
        jupyter = true,
        markdown = true,
      },
    }
    vim.keymap.set('n', '<leader>cc', function()
      local suggestion = require 'copilot.suggestion'
      suggestion.toggle_auto_trigger()
    end, { noremap = true, silent = true, desc = 'Toggle Copilot Auto Trigger' })
  end,
}
