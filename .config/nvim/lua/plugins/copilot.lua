return {
  'github/copilot.vim',
  config = function()
    -- Disable default Tab mapping for Copilot
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ''

    -- Custom keybindings for Copilot
    vim.api.nvim_set_keymap('i', '<C-e>', 'copilot#AcceptWord()', { silent = true, expr = true, script = true })
    vim.api.nvim_set_keymap('i', '<C-d>', 'copilot#Accept()', { silent = true, expr = true, script = true })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'jupyter',
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'i', '<C-d>', 'copilot#AcceptWord()', { silent = true, expr = true, script = true })
      end,
    })

    -- Function to toggle Copilot
    function _G.toggle_copilot()
      if vim.g.copilot_enabled == 1 then
        vim.cmd 'Copilot disable'
        print 'Copilot Disabled'
      else
        vim.cmd 'Copilot enable'
        print 'Copilot Enabled'
      end
    end

    -- Key mapping to toggle Copilot
    vim.api.nvim_set_keymap('n', '<leader>tt', ':lua toggle_copilot()<CR>', { noremap = true, silent = true })
  end,
}
