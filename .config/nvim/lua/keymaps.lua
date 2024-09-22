-- Yank entire file (remapped to avoid conflict)
vim.keymap.set('n', 'yaf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Function to copy file path and content to clipboard
local function copy_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local file_content = table.concat(lines, '\n')
  local clipboard_content = string.format('# %s\n%s', file_path, file_content)
  vim.fn.setreg('+', clipboard_content)
  return #lines
end

-- Function to append file path and content to clipboard
local function append_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local file_content = table.concat(lines, '\n')
  local clipboard_content = string.format('# %s\n%s', file_path, file_content)
  local current_clipboard = vim.fn.getreg '+'
  if current_clipboard == nil or current_clipboard == '' then
    -- Clipboard is empty, set the new content
    vim.fn.setreg('+', clipboard_content)
  else
    -- Append to existing clipboard content
    vim.fn.setreg('+', current_clipboard .. '\n\n' .. clipboard_content)
  end
  return #lines, #vim.split(vim.fn.getreg '+', '\n')
end

-- Function to clear the clipboard
local function clear_clipboard()
  local current_clipboard = vim.fn.getreg '+'
  local lines_cleared = #vim.split(current_clipboard, '\n')
  vim.fn.setreg('+', '')
  return lines_cleared
end

-- Function to highlight the entire buffer
local function highlight_entire_buffer()
  local ns_id = vim.api.nvim_create_namespace 'highlight_yac'
  local buf = 0 -- Current buffer
  local start_pos = { 0, 0 } -- Start at line 0, column 0
  local end_line = vim.api.nvim_buf_line_count(buf) - 1
  -- Handle empty buffer case
  local end_col = 0
  if end_line >= 0 then
    local last_line = vim.api.nvim_buf_get_lines(buf, end_line, end_line + 1, false)[1]
    end_col = last_line and #last_line or 0
  end
  vim.highlight.range(buf, ns_id, 'IncSearch', start_pos, { end_line, end_col }, { inclusive = true })
  -- Clear the highlight after a timeout
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  end, 150)
end

-- Keymap to copy file path and content (replacing clipboard)
vim.keymap.set('n', 'yac', function()
  local lines_yanked = copy_file_path_and_content()
  highlight_entire_buffer()
  print(string.format('File path and content copied to clipboard (%d lines)', lines_yanked))
end, { noremap = true, silent = true, desc = 'Copy file path and content to clipboard' })

-- Keymap to append file path and content to clipboard
vim.keymap.set('n', 'yaa', function()
  local lines_added, total_lines = append_file_path_and_content()
  highlight_entire_buffer()
  print(string.format('File path and content appended to clipboard (%d lines added, %d lines total)', lines_added, total_lines))
end, { noremap = true, silent = true, desc = 'Append file path and content to clipboard' })

-- Keymap to clear the clipboard
vim.keymap.set('n', 'ycc', function()
  local lines_cleared = clear_clipboard()
  print(string.format('Clipboard cleared (%d lines)', lines_cleared))
end, { noremap = true, silent = true, desc = 'Clear clipboard' })
