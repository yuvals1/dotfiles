-- File: lua/custom/plugins/iron/keymaps.lua
local M = {}

M.setup = function(iron, executor)
  -- Create user commands
  vim.api.nvim_create_user_command('IronExecuteLineAndMove', executor.execute_line_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteLine', executor.execute_line, {})
  vim.api.nvim_create_user_command('IronSmartExecute', executor.smart_execute, {})
  vim.api.nvim_create_user_command('IronSmartExecuteAndMove', executor.smart_execute_and_move, {})
  vim.api.nvim_create_user_command('IronExecuteFile', executor.execute_file, {})
  vim.api.nvim_create_user_command('IronExecuteUntilCursor', executor.execute_until_cursor, {})

  -- Set up keymaps
  vim.keymap.set('n', '<space>jj', function()
    iron.repl_for(vim.bo.filetype)
  end, { noremap = true, silent = true, desc = 'Toggle REPL' })

  vim.keymap.set('n', '<space>jx', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('n', '<C-y>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute Python construct' })
  vim.keymap.set('n', '<CR>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('i', '<C-y>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute Python construct' })
  vim.keymap.set('i', '<CR>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute Python construct and move' })
  vim.keymap.set('v', '<CR>', executor.smart_execute_and_move, { noremap = true, silent = true, desc = 'Smart execute selection and move' })
  vim.keymap.set('v', '<C-y>', executor.smart_execute, { noremap = true, silent = true, desc = 'Smart execute selection' })

  -- New keymaps for execute file and execute until cursor
  vim.keymap.set('n', '<space>jf', executor.execute_file, { noremap = true, silent = true, desc = 'Execute entire file' })
  vim.keymap.set('n', '<space>ju', executor.execute_until_cursor, { noremap = true, silent = true, desc = 'Execute until cursor' })

  -- New keymapping for clearing signs and restarting REPL
  vim.keymap.set('n', '<space>jr', ':IronClearAndRestart<CR>', { noremap = true, silent = true, desc = 'Clear signs and restart REPL' })

  vim.keymap.set('n', '<leader>wo', '<C-w>p', { noremap = true, silent = true, desc = 'Go to previous (last accessed) window' })
end

return M
