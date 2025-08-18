-- Custom command for GoToFile
vim.api.nvim_create_user_command('GoToFile', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local filepath

  filepath = line:match '"([^"]+)"' or line:match "'([^']+)'" or line:match '`([^`]+)`'

  if not filepath then
    local left = line:sub(1, col):reverse():find '[^%w%./\\-_]'
    local right = line:sub(col + 1):find '[^%w%./\\-_]'
    left = left and col - left + 1 or 1
    right = right and col + right or #line
    filepath = line:sub(left, right)
  end

  if filepath then
    filepath = vim.fn.expand(filepath)
    if vim.fn.filereadable(filepath) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
    else
      print('File not found: ' .. filepath)
    end
  else
    print 'No file path found under cursor'
  end
end, {})

-- Go to file
vim.api.nvim_set_keymap('n', 'gf', ':GoToFile<CR>', { noremap = true, silent = true })
