local M = {}

M.setup = function(iron, custom_functions)
  -- Create user commands
  vim.api.nvim_create_user_command('IronExecuteCell', custom_functions.execute_cell, {})
  vim.api.nvim_create_user_command('IronExecuteAndMove', custom_functions.execute_cell_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteLineAndMove', custom_functions.execute_line_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteLine', custom_functions.execute_line, {})
  vim.api.nvim_create_user_command('IronCreateCellBelow', custom_functions.create_cell_below, {})
  vim.api.nvim_create_user_command('IronRemoveCurrentCell', custom_functions.remove_current_cell, {})

  -- Set up keymaps
  vim.keymap.set('n', '<space>jj', function()
    iron.repl_for(vim.bo.filetype)
  end, { noremap = true, silent = true, desc = 'Toggle REPL' })

  vim.keymap.set('n', '<space>jm', custom_functions.execute_cell, { noremap = true, silent = true, desc = 'Execute current cell' })
  vim.keymap.set('n', '<space>jn', custom_functions.execute_cell_and_move, { noremap = true, silent = true, desc = 'Execute current cell and move to next' })
  vim.keymap.set('n', '<space>jl', custom_functions.execute_line_and_move, { noremap = true, silent = true, desc = 'Execute current line and move to next' })
  vim.keymap.set('n', '<space>je', custom_functions.execute_line, { noremap = true, silent = true, desc = 'Execute current line' })
  vim.keymap.set('n', '<space>jc', custom_functions.create_cell_below, { noremap = true, silent = true, desc = 'Create cell below' })
  vim.keymap.set('n', '<space>jd', custom_functions.remove_current_cell, { noremap = true, silent = true, desc = 'Remove current cell' })

  vim.keymap.set('n', '<leader>wo', '<C-w>p', { noremap = true, silent = true, desc = 'Go to previous (last accessed) window' })
end

return M
