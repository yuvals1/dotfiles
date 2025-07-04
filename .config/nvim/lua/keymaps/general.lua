--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Normal mode: delete to start of word
vim.keymap.set('n', '<M-BS>', 'db', { noremap = true, silent = true })

-- Insert mode: delete to start of word
vim.keymap.set('i', '<M-BS>', '<C-o>db', { noremap = true, silent = true })

-- Normal moded: move 10 lines up or down
vim.keymap.set({ 'n', 'v' }, '<F13>', '10k', { desc = 'Move 10 lines up' })
vim.keymap.set({ 'n', 'v' }, '<C-]>', '10j', { desc = 'Move 10 lines down' })

vim.keymap.set('i', '<C-a>', '<ESC><C-a>a', { desc = 'Increment number while in insert mode' })
vim.keymap.set('i', '<C-x>', '<ESC><C-x>a', { desc = 'Decrement number while in insert mode' })

vim.keymap.set('n', 'J', '/<C-r><C-w><CR>', { noremap = true })

vim.keymap.set('n', '<C-d>', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<C-u>', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })

-- Map F14 (remapped from Ctrl-i) to kill to end of line in insert mode
vim.keymap.set('i', '<F20>', '<C-o>D', { noremap = true, desc = 'Kill to end of line' })

-- Map shift-H and shift-L to move to start/end of line in visual mode
vim.keymap.set('v', 'H', '^', { noremap = true, desc = 'Move to start of line' })
vim.keymap.set('v', 'L', '$', { noremap = true, desc = 'Move to end of line' })
