local cycle_window_command = 'wincmd w'
local cycle_window_reverse_command = 'wincmd W'

vim.api.nvim_set_keymap('n', '<leader><leader>', ':' .. cycle_window_command .. '<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ww', ':' .. cycle_window_command .. '<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>W', ':' .. cycle_window_reverse_command .. '<CR>', { noremap = true, silent = true })
