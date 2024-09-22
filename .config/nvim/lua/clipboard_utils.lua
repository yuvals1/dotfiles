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
  local metadata = string.format('[file]%s|%d\n', file_path, line_count)
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
  local metadata_entries = M.get_metadata_entries()
  local already_copied = false
  for _, entry in ipairs(metadata_entries) do
    if entry.type == 'file' and entry.path == file_path then
      already_copied = true
      break
    end
  end

  -- Calculate total lines before adding new content
  local total_lines = 0
  for _, entry in ipairs(metadata_entries) do
    total_lines = total_lines + entry.lines
  end

  if already_copied then
    -- File already copied
    -- Read the full content file and yank it into the clipboard
    local content_file = io.open(tmp_content_file, 'r')
    local full_content = content_file:read '*a'
    content_file:close()
    vim.fn.setreg('+', full_content)

    return 0, total_lines, true
  else
    -- Append content to the temporary content file
    local content = string.format('\n\n# %s\n%s', file_path, table.concat(lines, '\n'))
    local content_file = io.open(tmp_content_file, 'a')
    content_file:write(content)
    content_file:close()

    -- Update metadata
    table.insert(metadata_entries, {
      type = 'file',
      path = file_path,
      lines = line_count,
    })
    M.write_metadata_entries(metadata_entries)

    -- Read the full content file and yank it into the clipboard
    content_file = io.open(tmp_content_file, 'r')
    local full_content = content_file:read '*a'
    content_file:close()
    vim.fn.setreg('+', full_content)

    -- Update total_lines by adding the new lines
    total_lines = total_lines + line_count

    return line_count, total_lines, false
  end
end

-- Function to get visual selection content
function M.get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()

  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    -- Swap the positions
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local lines = vim.fn.getline(start_line, end_line)

  if #lines == 0 then
    return ''
  end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    -- Adjust the first line
    lines[1] = string.sub(lines[1], start_col)
    -- Adjust the last line
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  return table.concat(lines, '\n')
end

-- Function to append visual selection as snippet to the temporary files and update clipboard
function M.append_visual_selection()
  -- Get visual selection content
  local snippet_content = M.get_visual_selection()
  if snippet_content == '' then
    vim.notify('No visual selection found', vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.split(snippet_content, '\n')
  local line_count = #lines

  -- Determine the next snippet number
  local snippet_number = M.get_next_snippet_number()

  -- Append snippet to the temporary content file
  local content = string.format('\n\n## Snippet %d in %s\n%s', snippet_number, file_path, snippet_content)
  local content_file = io.open(tmp_content_file, 'a')
  content_file:write(content)
  content_file:close()

  -- Update metadata
  local metadata_entries = M.get_metadata_entries()
  table.insert(metadata_entries, {
    type = 'snippet',
    number = snippet_number,
    path = file_path,
    lines = line_count,
  })
  M.write_metadata_entries(metadata_entries)

  -- Read the full content file and yank it into the clipboard
  content_file = io.open(tmp_content_file, 'r')
  local full_content = content_file:read '*a'
  content_file:close()
  vim.fn.setreg('+', full_content)

  return snippet_number, line_count
end

-- Function to get the next snippet number
function M.get_next_snippet_number()
  local snippet_number = 1
  local metadata_entries = M.get_metadata_entries()
  for _, entry in ipairs(metadata_entries) do
    if entry.type == 'snippet' and entry.number >= snippet_number then
      snippet_number = entry.number + 1
    end
  end
  return snippet_number
end

-- Function to get metadata entries
function M.get_metadata_entries()
  local metadata_entries = {}
  local metadata_file = io.open(tmp_metadata_file, 'r')
  if metadata_file then
    for line in metadata_file:lines() do
      if line:match '^%[file%]' then
        local path, count = line:match '^%[file%](.-)|(%d+)$'
        table.insert(metadata_entries, { type = 'file', path = path, lines = tonumber(count) })
      elseif line:match '^%[snippet%]' then
        local number, path, count = line:match '^%[snippet%](%d+)|(.-)|(%d+)$'
        table.insert(metadata_entries, {
          type = 'snippet',
          number = tonumber(number),
          path = path,
          lines = tonumber(count),
        })
      end
    end
    metadata_file:close()
  end
  return metadata_entries
end

-- Function to write metadata entries
function M.write_metadata_entries(entries)
  local metadata_file = io.open(tmp_metadata_file, 'w')
  for _, entry in ipairs(entries) do
    if entry.type == 'file' then
      metadata_file:write(string.format('[file]%s|%d\n', entry.path, entry.lines))
    elseif entry.type == 'snippet' then
      metadata_file:write(string.format('[snippet]%d|%s|%d\n', entry.number, entry.path, entry.lines))
    end
  end
  metadata_file:close()
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

return M
