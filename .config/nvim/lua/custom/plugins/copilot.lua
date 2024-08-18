return {
  'github/copilot.vim',
  config = function()
    -- Disable default Tab mapping for Copilot
    vim.g.copilot_no_tab_map = true

    -- Custom keybindings for Copilot
    vim.api.nvim_set_keymap('i', '<C-d>', '<Plug>(copilot-accept-word)', { silent = true })
    vim.api.nvim_set_keymap('i', '<C-f>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
    vim.api.nvim_set_keymap('i', '<C-]>', '<Plug>(copilot-dismiss)', { silent = true })
    vim.api.nvim_set_keymap('i', '<M-]>', '<Plug>(copilot-next)', { silent = true })
    vim.api.nvim_set_keymap('i', '<M-[>', '<Plug>(copilot-previous)', { silent = true })
    vim.api.nvim_set_keymap('i', '<M-\\>', '<Plug>(copilot-suggest)', { silent = true })

    -- You can add more custom configurations here
  end,
}
