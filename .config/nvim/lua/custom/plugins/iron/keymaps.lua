-- File: lua/custom/plugins/iron/keymaps.lua
local M = {}

M.setup = function(iron, executor, cells)
  -- Create user commands
  vim.api.nvim_create_user_command('IronExecuteCell', executor.execute_cell, {})
  vim.api.nvim_create_user_command('IronExecuteAndMove', executor.execute_cell_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteLineAndMove', executor.execute_line_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteLine', executor.execute_line, {})
  vim.api.nvim_create_user_command('IronCreateCellBelow', cells.create_cell_below, {})
  vim.api.nvim_create_user_command('IronRemoveCurrentCell', cells.remove_current_cell, {})
  vim.api.nvim_create_user_command('IronSmartExecute', executor.smart_execute, {})
  vim.api.nvim_create_user_command('IronSmartExecuteAndMove', executor.smart_execute_and_move, {})

  -- Set up keymaps
  vim.keymap.set('n', '<space>jj', function()
    iron.repl_for(vim.bo.filetype)
  end, { noremap = true, silent = true, desc = 'Toggle REPL' })

  vim.keymap.set('n', '<space>jl', executor.execute_line_and_move, { noremap = true, silent = true, desc = 'Execute current line and move to next' })
  vim.keymap.set('n', '<space>je', executor.execute_line, { noremap = true, silent = true, desc = 'Execute current line' })
  vim.keymap.set('n', '<space>js', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute Python construct' })
  vim.keymap.set('n', '<space>jx', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('n', '<C-p>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute Python construct' })
  vim.keymap.set('n', '<C-n>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('i', '<C-p>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute Python construct' })
  vim.keymap.set('i', '<C-n>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('v', '<C-n>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute selection and move' })
  vim.keymap.set('v', '<C-p>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute selection' })

  vim.keymap.set('n', '<space>jr', ':IronRestart<CR>', { noremap = true, silent = true, desc = 'Restart REPL' })

  -- Keymapping for cleaning signs
  vim.keymap.set('n', '<space>jc', ':IronCleanSigns<CR>', { noremap = true, silent = true, desc = 'Clean execution signs' })

  -- New keymapping for clearing signs and restarting REPL
  vim.keymap.set('n', '<space>jR', ':IronClearAndRestart<CR>', { noremap = true, silent = true, desc = 'Clear signs and restart REPL' })

  vim.keymap.set('n', '<leader>wo', '<C-w>p', { noremap = true, silent = true, desc = 'Go to previous (last accessed) window' })
end

return M
