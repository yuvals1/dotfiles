return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
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
      },
    }
    vim.keymap.set('n', '<leader>tt', '<cmd>Copilot toggle<CR>', { noremap = true, silent = true, desc = 'Toggle Copilot' })
  end,
}
