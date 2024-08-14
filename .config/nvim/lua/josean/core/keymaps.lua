-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>xx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>te", "<cmd>e<CR>", { desc = "Refresh current file" }) -- close current split window

keymap.set("n", "<leader>nb", "<cmd>Navbuddy<CR>", { desc = "Open Navbuddy" }) -- close current split window

keymap.set("n", "<C-M>", "o<Esc>", { desc = "Add new line below without exiting normal mode" })
keymap.set("n", "<C-S-M>", "O<Esc>", { desc = "Add new line above without exiting normal mode" })

-- Lspsaga keymaps
keymap.set("n", "<leader>lc", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
keymap.set("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Outline" })
keymap.set("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })
keymap.set("n", "<leader>ld", "<cmd>Lspsaga goto_definition<CR>", { desc = "Lsp GoTo Definition" })
keymap.set("n", "<leader>lf", "<cmd>Lspsaga finder<CR>", { desc = "Lsp Finder" })
keymap.set("n", "<leader>lp", "<cmd>Lspsaga preview_definition<CR>", { desc = "Preview Definition" })
keymap.set("n", "<leader>ls", "<cmd>Lspsaga signature_help<CR>", { desc = "Signature Help" })
keymap.set("n", "<leader>lw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", { desc = "Show Workspace Diagnostics" })

-- outline keymaps
keymap.set("n", "<leader>ll", "<cmd>Outline<CR>", { desc = "Show Outline" })
