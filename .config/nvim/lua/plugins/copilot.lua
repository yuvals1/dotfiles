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

    -- Create a function to toggle Copilot
    local function toggle_copilot()
      local ok, copilot_suggestion = pcall(require, 'copilot.suggestion')
      if ok then
        copilot_suggestion.toggle_auto_trigger()
        -- Print status
        local status = vim.b.copilot_suggestion_auto_trigger and 'enabled' or 'disabled'
        vim.notify('Copilot ' .. status, vim.log.levels.INFO)
      end
    end

    -- Set up the toggle keymap
    vim.keymap.set('n', '<leader>tt', toggle_copilot, { noremap = true, silent = true, desc = 'Toggle Copilot' })
  end,
}
