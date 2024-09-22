local clipboard_utils = require 'clipboard_utils'
local visual_utils = require 'visual_utils'

-- Yank entire file (remapped to avoid conflict)
vim.keymap.set('n', 'yaf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Keymap to copy file path and content (replacing clipboard)
vim.keymap.set('n', 'yac', function()
  local lines_yanked = clipboard_utils.copy_file_path_and_content()
  visual_utils.highlight_entire_buffer()

  -- Build the message
  local message = string.format(
    'File path and content copied to clipboard (%d lines)\nFile:\n%s (%d)',
    lines_yanked,
    clipboard_utils.clipboard_files[1].path,
    clipboard_utils.clipboard_files[1].lines
  )

  -- Use vim.notify to display the message
  vim.notify(message, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Copy file path and content to clipboard' })

-- Keymap to append file path and content to clipboard
vim.keymap.set('n', 'yaa', function()
  local lines_added, total_lines, already_copied = clipboard_utils.append_file_path_and_content()

  if already_copied then
    -- Build the file paths message with line counts
    local file_paths_message = ''
    for _, file in ipairs(clipboard_utils.clipboard_files) do
      file_paths_message = file_paths_message .. string.format('%s (%d)\n', file.path, file.lines)
    end
    -- Notify that the file has already been copied
    vim.notify('This file has already been copied to the clipboard.\nFiles:\n' .. file_paths_message, vim.log.levels.WARN)
  else
    visual_utils.highlight_entire_buffer()

    -- Build the file paths message with line counts
    local file_paths_message = ''
    for _, file in ipairs(clipboard_utils.clipboard_files) do
      file_paths_message = file_paths_message .. string.format('%s (%d)\n', file.path, file.lines)
    end

    -- Build the full message
    local message = string.format('File path and content appended to clipboard (%d lines total)\nFiles:\n%s', total_lines, file_paths_message)

    -- Use vim.notify to display the message
    vim.notify(message, vim.log.levels.INFO)
  end
end, { noremap = true, silent = true, desc = 'Append file path and content to clipboard' })

-- Keymap to clear the clipboard
vim.keymap.set('n', 'ycc', function()
  local lines_cleared = clipboard_utils.clear_clipboard()
  -- Use vim.notify to display the message
  vim.notify(string.format('Clipboard cleared (%d lines)', lines_cleared), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Clear clipboard' })
