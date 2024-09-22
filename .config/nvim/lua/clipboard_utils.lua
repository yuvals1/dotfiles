-- clipboard_utils.lua

local M = {}

-- Paths to temporary files
local tmp_content_file = '/tmp/clipboard_content.txt'
local tmp_metadata_file = '/tmp/clipboard_metadata.txt'

-- Function to copy file path and content to a temporary file and clipboard
function M.copy_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines
  local file_content = table.concat(lines, '\n')
  local content = string.format('# %s\n%s', file_path, file_content)

  -- Write content to the temporary content file
  local content_file = io.open(tmp_content_file, 'w')
  content_file:write(content)
  content_file:close()

  -- Write metadata to the temporary metadata file
  local metadata = string.format('%s|%d\n', file_path, line_count)
  local metadata_file = io.open(tmp_metadata_file, 'w')
  metadata_file:write(metadata)
  metadata_file:close()

  -- Yank the full content into the clipboard
  vim.fn.setreg('+', content)

  return line_count
end

-- Function to append file path and content to the temporary files and update clipboard
function M.append_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = #lines

  -- Read existing metadata
  local metadata_entries = {}
  local metadata_file = io.open(tmp_metadata_file, 'r')
  if metadata_file then
    for line in metadata_file:lines() do
      local path, count = line:match '^(.*)|(%d+)$'
      metadata_entries[path] = tonumber(count)
    end
    metadata_file:close()
  end

  -- Check if the file has already been copied
  if metadata_entries[file_path] then
    -- File already copied
    -- Calculate total lines
    local total_lines = 0
    for _, count in pairs(metadata_entries) do
      total_lines = total_lines + count
    end

    -- Read the full content file and yank it into the clipboard
    local content_file = io.open(tmp_content_file, 'r')
    local full_content = content_file:read '*a'
    content_file:close()
    vim.fn.setreg('+', full_content)

    return 0, total_lines, true
  end

  -- Append content to the temporary content file
  local content = string.format('\n\n# %s\n%s', file_path, table.concat(lines, '\n'))
  local content_file = io.open(tmp_content_file, 'a')
  content_file:write(content)
  content_file:close()

  -- Update metadata
  metadata_entries[file_path] = line_count
  metadata_file = io.open(tmp_metadata_file, 'w')
  for path, count in pairs(metadata_entries) do
    metadata_file:write(string.format('%s|%d\n', path, count))
  end
  metadata_file:close()

  -- Read the full content file and yank it into the clipboard
  content_file = io.open(tmp_content_file, 'r')
  local full_content = content_file:read '*a'
  content_file:close()
  vim.fn.setreg('+', full_content)

  -- Calculate total lines
  local total_lines = 0
  for _, count in pairs(metadata_entries) do
    total_lines = total_lines + count
  end

  return line_count, total_lines, false
end

-- Function to clear the temporary files and clear the clipboard
function M.clear_clipboard()
  local lines_cleared = 0

  -- Count the number of lines before clearing
  local content_file = io.open(tmp_content_file, 'r')
  if content_file then
    for _ in content_file:lines() do
      lines_cleared = lines_cleared + 1
    end
    content_file:close()
  end

  -- Delete the temporary files
  os.remove(tmp_content_file)
  os.remove(tmp_metadata_file)

  -- Clear the clipboard
  vim.fn.setreg('+', '')

  return lines_cleared
end

-- Function to get metadata entries
function M.get_clipboard_files()
  local metadata_entries = {}
  local metadata_file = io.open(tmp_metadata_file, 'r')
  if metadata_file then
    for line in metadata_file:lines() do
      local path, count = line:match '^(.*)|(%d+)$'
      table.insert(metadata_entries, { path = path, lines = tonumber(count) })
    end
    metadata_file:close()
  end
  return metadata_entries
end

return M
