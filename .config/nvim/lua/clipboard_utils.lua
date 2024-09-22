local M = {}

-- Initialize a list to store files with their line counts
M.clipboard_files = {}

-- Function to copy file path and content to clipboard
function M.copy_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines
  local file_content = table.concat(lines, '\n')
  local clipboard_content = string.format('# %s\n%s', file_path, file_content)
  vim.fn.setreg('+', clipboard_content)

  -- Update the clipboard_files list
  M.clipboard_files = { { path = file_path, lines = line_count } }
  return line_count
end

-- Function to append file path and content to clipboard
function M.append_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines

  -- Check if the file has already been copied
  local already_copied = false
  for _, file in ipairs(M.clipboard_files) do
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
  table.insert(M.clipboard_files, 1, { path = file_path, lines = line_count })

  return line_count, #vim.split(vim.fn.getreg '+', '\n'), false
end

-- Function to clear the clipboard
function M.clear_clipboard()
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
  M.clipboard_files = {}

  return lines_cleared
end

return M
