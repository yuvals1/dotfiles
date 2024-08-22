return {
  'github/copilot.vim',
  config = function()
    -- Disable default Tab mapping for Copilot
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ''
    -- Custom keybindings for Copilot
    -- vim.api.nvim_set_keymap('i', '<C-d>', '<Plug>(copilot-accept-word)', { silent = true })
    vim.api.nvim_set_keymap('i', '<C-d>', 'copilot#AcceptWord()', { silent = true, expr = true, script = true })

    vim.api.nvim_set_keymap('i', '<C-f>', 'copilot#Accept()', { silent = true, expr = true, script = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'jupyter',
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'i', '<C-d>', 'copilot#AcceptWord()', { silent = true, expr = true, script = true })
      end,
    })
    -- You can add more custom configurations here
  end,
}
