return {
  'supermaven-inc/supermaven-nvim',
  event = { 'InsertEnter', 'LspAttach' },
  config = function()
    require('supermaven-nvim').setup {
      keymaps = {
        accept_suggestion = '<C-d>',
        accept_word = '<C-e>',
        clear_suggestion = '<C-]>',
      },
      -- Enable for specific filetypes (similar to your Copilot config)
      ignore_filetypes = {
        -- Add filetypes you want to disable here
        -- Format: filetype = true
      },
      -- Color customization (optional)
      color = {
        suggestion_color = '#ffffff',
        cterm = 244,
      },
      -- Logging level
      log_level = 'info',
      -- Keep inline completion enabled (similar to Copilot)
      disable_inline_completion = false,
    }

    -- Add toggle keybinding similar to your Copilot config
    vim.keymap.set('n', '<leader>cc', ':SupermavenToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Supermaven' })
  end,
}
