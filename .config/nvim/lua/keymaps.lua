-- Initialize a list to store files with their line counts
local clipboard_files = {}

-- Yank entire file (remapped to avoid conflict)
vim.keymap.set('n', 'yaf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Function to copy file path and content to clipboard
local function copy_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines
  local file_content = table.concat(lines, '\n')
  local clipboard_content = string.format('# %s\n%s', file_path, file_content)
  vim.fn.setreg('+', clipboard_content)

  -- Update the clipboard_files list
  clipboard_files = { { path = file_path, lines = line_count } }
  return line_count
end

-- Function to append file path and content to clipboard
local function append_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines

  -- Check if the file has already been copied
  local already_copied = false
  for _, file in ipairs(clipboard_files) do
    if file.path == file_path then
      already_copied = true
      break
    end
  end

  if already_copied then
    return 0, #vim.split(vim.fn.getreg '+', '\n'), true -- Indicate that the file was already copied
  end

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

  -- Add the file with its line count to the beginning of the list
  table.insert(clipboard_files, 1, { path = file_path, lines = line_count })

  return line_count, #vim.split(vim.fn.getreg '+', '\n'), false
end

-- Function to clear the clipboard
local function clear_clipboard()
  local current_clipboard = vim.fn.getreg '+'
  local lines_cleared = #vim.split(current_clipboard, '\n')

  -- Clear the system clipboard using external commands
  local uname = vim.loop.os_uname()
  if uname.sysname == 'Darwin' then
    -- macOS
    vim.fn.system 'pbcopy < /dev/null'
  elseif uname.sysname == 'Linux' then
    -- Linux
    vim.fn.system 'xclip -selection clipboard /dev/null'
  elseif uname.sysname == 'Windows_NT' then
    -- Windows
    vim.fn.system 'echo off | clip'
  else
    -- Unsupported OS
    vim.fn.setreg('+', ' ', 'c') -- Fallback to setting a space
  end

  -- Clear the clipboard_files list
  clipboard_files = {}

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

  -- Build the message
  local message =
    string.format('File path and content copied to clipboard (%d lines)\nFile:\n%s (%d)', lines_yanked, clipboard_files[1].path, clipboard_files[1].lines)

  -- Use vim.notify to display the message
  vim.notify(message, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Copy file path and content to clipboard' })

-- Keymap to append file path and content to clipboard
vim.keymap.set('n', 'yaa', function()
  local lines_added, total_lines, already_copied = append_file_path_and_content()

  if already_copied then
    -- Build the file paths message with line counts
    local file_paths_message = ''
    for _, file in ipairs(clipboard_files) do
      file_paths_message = file_paths_message .. string.format('%s (%d)\n', file.path, file.lines)
    end
    -- Notify that the file has already been copied
    vim.notify('This file has already been copied to the clipboard.\nFiles:\n' .. file_paths_message, vim.log.levels.WARN)
  else
    highlight_entire_buffer()

    -- Build the file paths message with line counts
    local file_paths_message = ''
    for _, file in ipairs(clipboard_files) do
      file_paths_message = file_paths_message .. string.format('%s (%d)\n', file.path, file.lines)
    end

    -- Build the full message
    local message =
      string.format('File path and content appended to clipboard (%d lines added, %d lines total)\nFiles:\n%s', lines_added, total_lines, file_paths_message)

    -- Use vim.notify to display the message
    vim.notify(message, vim.log.levels.INFO)
  end
end, { noremap = true, silent = true, desc = 'Append file path and content to clipboard' })

-- Keymap to clear the clipboard
vim.keymap.set('n', 'ycc', function()
  local lines_cleared = clear_clipboard()
  -- Use vim.notify to display the message
  vim.notify(string.format('Clipboard cleared (%d lines)', lines_cleared), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Clear clipboard' })
