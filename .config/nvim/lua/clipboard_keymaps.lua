-- clipboard_keymaps.lua

local clipboard_utils = require 'clipboard_utils'
local visual_utils = require 'visual_utils'

-- Yank entire file (remapped to avoid conflict)
vim.keymap.set('n', 'yaf', ':%y<CR>', { noremap = true, silent = true, desc = 'Yank entire file' })

-- Keymap to copy file path and content (replacing clipboard)
vim.keymap.set('n', 'yac', function()
  local lines_yanked = clipboard_utils.copy_file_path_and_content()
  visual_utils.highlight_entire_buffer()

  -- Get metadata entries
  local entries = clipboard_utils.get_metadata_entries()

  -- Calculate total lines
  local total_lines = 0
  for _, entry in ipairs(entries) do
    total_lines = total_lines + entry.lines
  end

  -- Build the entries message
  local entries_message = ''
  for i = #entries, 1, -1 do -- Newest to oldest
    local entry = entries[i]
    if entry.type == 'file' then
      entries_message = entries_message .. string.format('%s (%d)\n', entry.path, entry.lines)
    elseif entry.type == 'snippet' then
      entries_message = entries_message .. string.format('snippet %d in %s (%d)\n', entry.number, entry.path, entry.lines)
    end
  end
  -- Indicate newest and oldest
  entries_message = entries_message:gsub('^(.-)\n', '%1 <- this is the newest\n', 1)
  entries_message = entries_message:gsub('([^\n]+)$', '%1 <- this is the oldest')

  -- Build the full message
  local message = string.format('File path and content copied to temporary file (%d lines total)\nFiles:\n%s', total_lines, entries_message)

  -- Use vim.notify to display the message
  vim.notify(message, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Copy file path and content to temp file' })

-- Keymap to append file path and content to temporary files
vim.keymap.set('n', 'yaa', function()
  local lines_added, total_lines, already_copied = clipboard_utils.append_file_path_and_content()

  local entries = clipboard_utils.get_metadata_entries()

  -- Build the entries message
  local entries_message = ''
  for i = #entries, 1, -1 do -- Newest to oldest
    local entry = entries[i]
    if entry.type == 'file' then
      entries_message = entries_message .. string.format('%s (%d)\n', entry.path, entry.lines)
    elseif entry.type == 'snippet' then
      entries_message = entries_message .. string.format('snippet %d in %s (%d)\n', entry.number, entry.path, entry.lines)
    end
  end
  -- Indicate newest and oldest
  entries_message = entries_message:gsub('^(.-)\n', '%1 <- this is the newest\n', 1)
  entries_message = entries_message:gsub('([^\n]+)$', '%1 <- this is the oldest')

  if already_copied then
    -- Notify that the file has already been copied
    local message = string.format('This file has already been copied.\nFiles:\n%s', entries_message)
    vim.notify(message, vim.log.levels.WARN)
  else
    visual_utils.highlight_entire_buffer()
    -- Build the full message
    local message = string.format('Appended new file (%d lines total)\nFiles:\n%s', total_lines, entries_message)
    -- Use vim.notify to display the message
    vim.notify(message, vim.log.levels.INFO)
  end
end, { noremap = true, silent = true, desc = 'Append file path and content to temp file' })

-- Keymap to append visual selection as snippet to temporary files
vim.keymap.set('v', 'yav', function()
  local snippet_number, lines_added = clipboard_utils.append_visual_selection()
  if snippet_number then
    -- Get metadata entries
    local entries = clipboard_utils.get_metadata_entries()

    -- Calculate total lines
    local total_lines = 0
    for _, entry in ipairs(entries) do
      total_lines = total_lines + entry.lines
    end

    -- Build the entries message
    local entries_message = ''
    for i = #entries, 1, -1 do -- Newest to oldest
      local entry = entries[i]
      if entry.type == 'file' then
        entries_message = entries_message .. string.format('%s (%d)\n', entry.path, entry.lines)
      elseif entry.type == 'snippet' then
        entries_message = entries_message .. string.format('snippet %d in %s (%d)\n', entry.number, entry.path, entry.lines)
      end
    end
    -- Indicate newest and oldest
    entries_message = entries_message:gsub('^(.-)\n', '%1 <- this is the newest\n', 1)
    entries_message = entries_message:gsub('([^\n]+)$', '%1 <- this is the oldest')

    -- Build the full message
    local message = string.format('Appended new snippet (%d lines total)\nFiles:\n%s', total_lines, entries_message)

    -- Use vim.notify to display the message
    vim.notify(message, vim.log.levels.INFO)
    -- Highlight the selection
    visual_utils.highlight_selection()
  end
end, { noremap = true, silent = true, desc = 'Append visual selection as snippet to temp file' })

-- Keymap to clear the temporary files
vim.keymap.set('n', 'ycc', function()
  local lines_cleared = clipboard_utils.clear_clipboard()
  -- Use vim.notify to display the message
  vim.notify(string.format('Temporary files cleared (%d lines)', lines_cleared), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Clear temporary files' })
