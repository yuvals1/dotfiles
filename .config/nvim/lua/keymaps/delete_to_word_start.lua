-- Function to delete to word start in insert mode
function DeleteToWordStart()
  -- Save the current cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- Get the current line
  local line = vim.api.nvim_get_current_line()

  -- Find the start of the current word
  local word_start = col
  while word_start > 0 and line:sub(word_start, word_start):match '%s' do
    word_start = word_start - 1
  end
  while word_start > 0 and not line:sub(word_start, word_start):match '%s' do
    word_start = word_start - 1
  end

  -- Delete from cursor to word start
  if word_start < col then
    local new_line = line:sub(1, word_start) .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, word_start })
  end

  -- Return to insert mode
  vim.cmd 'startinsert'
end

-- Map Option+Backspace to the custom function in insert mode
vim.keymap.set('i', '<M-BS>', '<Cmd>lua DeleteToWordStart()<CR>', { noremap = true, silent = true })
