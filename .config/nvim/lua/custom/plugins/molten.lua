return {
  'benlubas/molten-nvim',
  version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
  dependencies = {
    '3rd/image.nvim', -- optional; for image support
  },
  build = ':UpdateRemotePlugins',
  init = function()
    -- Configuration options
    vim.g.molten_output_win_max_height = 12
    vim.g.molten_auto_open_output = false
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true

    -- Split window to the right
    vim.g.molten_output_win_style = 'minimal'
    vim.g.molten_output_win_cover_gutter = false
    vim.g.molten_output_win_border = { '', '━', '', '' }
    vim.g.molten_output_win_max_width = math.floor(vim.o.columns * 0.4) -- 40% of screen width

    -- Use image.nvim for image rendering (optional)
    vim.g.molten_image_provider = 'image.nvim'

    -- Keybindings
    vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Initialize Molten' })
    vim.keymap.set('n', '<localleader>me', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'Evaluate Operator' })
    vim.keymap.set('n', '<localleader>ml', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'Evaluate Line' })
    vim.keymap.set('n', '<localleader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 'Re-evaluate Cell' })
    vim.keymap.set('v', '<localleader>mv', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'Evaluate Visual Selection' })
    vim.keymap.set('n', '<localleader>mo', ':MoltenShowOutput<CR>', { silent = true, desc = 'Show Output' })
    vim.keymap.set('n', '<localleader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'Hide Output' })
    vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { silent = true, desc = 'Delete Cell' })
  end,
}
