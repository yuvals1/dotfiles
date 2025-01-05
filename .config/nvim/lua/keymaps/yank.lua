vim.keymap.set('n', 'yf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Helper function to handle yanking with fallback
local function yank_with_fallback(content, description)
  -- Try system clipboard first
  local success = pcall(function()
    vim.fn.setreg('+', content)
  end)
  -- Fallback to unnamed register if system clipboard fails
  if not success then
    vim.fn.setreg('"', content)
  end
  vim.notify(description .. content, vim.log.levels.INFO)
end

-- Yank absolute path
vim.keymap.set('n', 'yp', function()
  local file_path = vim.fn.expand '%:p'
  yank_with_fallback(file_path, 'Yanked absolute path: ')
end, { noremap = true, desc = 'Yank absolute file path' })

-- Yank file name only
vim.keymap.set('n', 'yn', function()
  local file_name = vim.fn.expand '%:t'
  yank_with_fallback(file_name, 'Yanked file name: ')
end, { noremap = true, desc = 'Yank file name' })

-- Yank path relative to home directory
vim.keymap.set('n', 'yr', function()
  local abs_path = vim.fn.expand '%:p'
  local home = vim.fn.expand '$HOME'
  local rel_path = abs_path:gsub(home .. '/', '')
  yank_with_fallback(rel_path, 'Yanked home-relative path: ')
end, { noremap = true, desc = 'Yank path relative to home' })
