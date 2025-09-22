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
vim.keymap.set({ 'n', 'v' }, '<C-k>', '10gk', { desc = 'Move 10 lines up' })
vim.keymap.set({ 'n', 'v' }, '<C-j>', '10gj', { desc = 'Move 10 lines down' })

vim.keymap.set('i', '<C-a>', '<ESC><C-a>a', { desc = 'Increment number while in insert mode' })
vim.keymap.set('i', '<C-x>', '<ESC><C-x>a', { desc = 'Decrement number while in insert mode' })

vim.keymap.set('n', 'J', '/<C-r><C-w><CR>', { noremap = true })

vim.keymap.set('n', '<C-]>', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<F13>', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })


-- Map shift-H and shift-L to move to start/end of line in visual mode
vim.keymap.set('v', 'H', '^', { noremap = true, desc = 'Move to start of line' })
vim.keymap.set('v', 'L', '$', { noremap = true, desc = 'Move to end of line' })

-- Toggle line wrapping
vim.keymap.set('n', '<leader>wr', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify('Wrap: ' .. (vim.wo.wrap and 'on' or 'off'))
end, { desc = 'Toggle line wrapping' })

-- Move by visual lines when wrap is on (instead of actual lines)
-- This makes j/k behave more intuitively with wrapped lines
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Move down by visual line' })
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = 'Move up by visual line' })

-- Open Yazi in a full-screen terminal tab and auto-close on exit
local function open_yazi_tab()
  if vim.fn.executable('yazi') ~= 1 then
    vim.notify('yazi not found on PATH', vim.log.levels.ERROR)
    return
  end

  local dir
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= '' then
    dir = vim.fn.fnamemodify(bufname, ':p:h')
  else
    dir = vim.loop.cwd()
  end

  vim.cmd('tabnew')
  local term_buf = vim.api.nvim_get_current_buf()
  local chan = vim.fn.termopen('yazi', { cwd = dir })
  if chan <= 0 then
    vim.notify('failed to start yazi', vim.log.levels.ERROR)
    if vim.fn.tabpagenr('$') > 1 then vim.cmd('tabclose') end
    return
  end
  vim.cmd('startinsert')

  vim.api.nvim_create_autocmd('TermClose', {
    buffer = term_buf,
    once = true,
    callback = function()
      if vim.fn.tabpagenr('$') > 1 then
        vim.cmd('tabclose')
      else
        vim.cmd('bdelete!')
      end
    end,
  })
end

vim.api.nvim_create_user_command('YaziStandalone', open_yazi_tab, { desc = 'Open Yazi in a terminal tab' })
vim.keymap.set('n', 'g-', open_yazi_tab, { desc = 'Open Yazi (terminal tab)' })
