vim.keymap.set('n', 'yf', ':%y<CR><CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Yank absolute path (full path)
vim.keymap.set('n', 'yp', function()
  local file_path = vim.fn.expand '%:p'
  vim.fn.setreg('+', file_path)
  vim.notify('Yanked absolute path: ' .. file_path, vim.log.levels.INFO)
end, { noremap = true, desc = 'Yank absolute file path' })

-- Yank file name only
vim.keymap.set('n', 'yn', function()
  local file_name = vim.fn.expand '%:t'
  vim.fn.setreg('+', file_name)
  vim.notify('Yanked file name: ' .. file_name, vim.log.levels.INFO)
end, { noremap = true, desc = 'Yank file name' })

-- Yank path relative to home directory
vim.keymap.set('n', 'yr', function()
  local abs_path = vim.fn.expand '%:p'
  local home = vim.fn.expand '$HOME'
  local rel_path = abs_path:gsub(home .. '/', '')
  vim.fn.setreg('+', rel_path)
  vim.notify('Yanked home-relative path: ' .. rel_path, vim.log.levels.INFO)
end, { noremap = true, desc = 'Yank path relative to home' })
