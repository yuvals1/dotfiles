-- Add this to your init.lua or create a new mapping file

-- Normal mode: indent current line
vim.keymap.set('n', '<C-t>', '>>', { noremap = true, desc = 'Indent line' })

-- Insert mode: preserve default CTRL-T behavior (indent current line)
-- This is already built into Neovim, but you can explicitly set it if you want:
vim.keymap.set('i', '<C-t>', '<C-t>', { noremap = true, desc = 'Indent line' })

-- Visual mode (optional): indent selected text
vim.keymap.set('v', '<C-t>', '>', { noremap = true, desc = 'Indent selection' })

-- Reverse indentation with CTRL-G
vim.keymap.set('n', '<C-g>', '<<', { noremap = true, desc = 'Reverse indent line' })
vim.keymap.set('i', '<C-g>', '<C-o><<', { noremap = true, desc = 'Reverse indent line' })
vim.keymap.set('v', '<C-g>', '<', { noremap = true, desc = 'Reverse indent selection' })
