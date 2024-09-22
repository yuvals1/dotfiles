-- clipboard_keymaps.lua

local clipboard_utils = require 'clipboard_utils'
local visual_utils = require 'visual_utils'

-- Yank entire file (remapped to avoid conflict)
vim.keymap.set('n', 'yaf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Keymap to copy file path and content (replacing clipboard)
vim.keymap.set('n', 'yac', function()
  local lines_yanked = clipboard_utils.copy_file_path_and_content()
  visual_utils.highlight_entire_buffer()

  -- Build the message
  local message = string.format('File path and content copied to temporary file (%d lines)', lines_yanked)

  -- Use vim.notify to display the message
  vim.notify(message, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Copy file path and content to temp file' })

-- Keymap to append file path and content to temporary file
vim.keymap.set('n', 'yaa', function()
  local lines_added = clipboard_utils.append_file_path_and_content()
  visual_utils.highlight_entire_buffer()

  -- Build the message
  local message = string.format('File path and content appended to temporary file (%d lines)', lines_added)

  -- Use vim.notify to display the message
  vim.notify(message, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Append file path and content to temp file' })

-- Keymap to append visual selection as snippet to temporary file
vim.keymap.set('v', 'yav', function()
  local snippet_number = clipboard_utils.append_visual_selection()
  if snippet_number then
    -- Build the message
    local message = string.format('Snippet %d appended to temporary file', snippet_number)
    -- Use vim.notify to display the message
    vim.notify(message, vim.log.levels.INFO)
    -- Highlight the selection
    visual_utils.highlight_selection()
  end
end, { noremap = true, silent = true, desc = 'Append visual selection as snippet to temp file' })

-- Keymap to clear the temporary file
vim.keymap.set('n', 'ycc', function()
  local lines_cleared = clipboard_utils.clear_clipboard()
  -- Use vim.notify to display the message
  vim.notify(string.format('Temporary file cleared (%d lines)', lines_cleared), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Clear temporary file' })
