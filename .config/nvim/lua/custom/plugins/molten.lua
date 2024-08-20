return {
  'benlubas/molten-nvim',
  version = '^1.0.0',
  dependencies = {
    '3rd/image.nvim',
  },
  build = ':UpdateRemotePlugins',
  init = function()
    -- vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim/bin/python3'
    vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim311/bin/python3'
    vim.g.molten_output_win_style = 'inline'
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
    vim.g.molten_wrap_output = true
    vim.g.molten_output_crop_border = true
    vim.g.molten_output_win_hide_on_leave = false
    -- Keybindings
    vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Initialize Molten' })
    vim.keymap.set('n', '<localleader>me', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'Evaluate Operator' })
    vim.keymap.set('n', '<localleader>ml', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'Evaluate Line' })
    vim.keymap.set('n', '<localleader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 'Re-evaluate Cell' })
    vim.keymap.set('v', '<localleader>mv', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'Evaluate Visual Selection' })
    vim.keymap.set('n', '<localleader>mo', ':MoltenShowOutput<CR>', { silent = true, desc = 'Show Output' })
    vim.keymap.set('n', '<localleader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'Hide Output' })
    vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { silent = true, desc = 'Delete Cell' })

    -- Add a keybinding to enter the output window
    vim.keymap.set('n', '<localleader>oe', ':MoltenEnterOutput<CR>', { silent = true, desc = 'Enter Output Window' })
  end,
}
