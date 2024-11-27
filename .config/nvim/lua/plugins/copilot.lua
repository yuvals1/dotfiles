return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- Equivalent to your <C-d> mapping for accepting the whole suggestion
          accept = '<C-d>',
          -- Equivalent to your <C-e> mapping for accepting a word
          accept_word = '<C-e>',
          -- You might want to add these for navigation
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      -- Other configuration options
      filetypes = {
        -- Add any specific filetype configurations
        jupyter = true, -- Enable for jupyter files
        -- Add other filetypes as needed
      },
    }
    -- Set up the toggle keymap using the built-in command
    vim.keymap.set('n', '<leader>tt', '<cmd>Copilot toggle<CR>', { noremap = true, silent = true, desc = 'Toggle Copilot' })
  end,
}
