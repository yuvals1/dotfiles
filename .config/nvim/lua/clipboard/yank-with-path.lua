local clipboard_utils = require 'clipboard.clipboard_utils'
local visual_utils = require 'clipboard.visual_utils'

vim.keymap.set('n', 'yad', function()
  -- local lines_yanked = clipboard_utils.copy_file_path_and_content()
  visual_utils.highlight_entire_buffer()

  -- Get metadata entries
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines
  local file_content = table.concat(lines, '\n')
  local content = string.format('# %s\n%s', file_path, file_content)

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
