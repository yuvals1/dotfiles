-- Set leader key to space (if not already set)
vim.g.mapleader = ' '

-- Function to insert formatted time
local function insert_time(format)
  return function()
    local time = os.date(format)
    vim.api.nvim_put({ time }, 'c', true, true)
  end
end

-- Define mappings
vim.keymap.set('n', '<leader>t1', insert_time '%H:%M', { desc = 'Insert time (HH:MM:SS)' })
vim.keymap.set('n', '<leader>t2', insert_time '%Y-%m-%d', { desc = 'Insert date (YYYY-MM-DD)' })
vim.keymap.set('n', '<leader>t3', insert_time '%Y-%m-%d %H:%M:%S', { desc = 'Insert date and time' })
vim.keymap.set('n', '<leader>t4', insert_time '%c', { desc = 'Insert full date and time' })
vim.keymap.set('n', '<leader>t5', insert_time '%a %b %d %Y', { desc = 'Insert date (Day Mon DD YYYY)' })
