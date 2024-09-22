-- clipboard_utils.lua

local M = {}

-- Path to the temporary content file
local tmp_content_file = '/tmp/clipboard_content.txt'

-- Function to copy file path and content to a temporary file and clipboard
function M.copy_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local file_content = table.concat(lines, '\n')
  local content = string.format('# %s\n%s', file_path, file_content)

  -- Write content to the temporary content file
  local content_file = io.open(tmp_content_file, 'w')
  content_file:write(content)
  content_file:close()

  -- Yank the full content into the clipboard
  vim.fn.setreg('+', content)

  return #lines
end

-- Function to append file path and content to the temporary file and update clipboard
function M.append_file_path_and_content()
  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local file_content = table.concat(lines, '\n')
  local content = string.format('\n\n# %s\n%s', file_path, file_content)

  -- Append content to the temporary content file
  local content_file = io.open(tmp_content_file, 'a')
  content_file:write(content)
  content_file:close()

  -- Read the full content file and yank it into the clipboard
  content_file = io.open(tmp_content_file, 'r')
  local full_content = content_file:read '*a'
  content_file:close()
  vim.fn.setreg('+', full_content)

  return #lines
end

-- Function to append visual selection as snippet to the temporary file and update clipboard
function M.append_visual_selection()
  -- Get visual selection content
  local snippet_content = M.get_visual_selection()
  if snippet_content == '' then
    vim.notify('No visual selection found', vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')

  -- Determine the next snippet number
  local snippet_number = M.get_next_snippet_number()

  -- Append snippet to the temporary content file
  local content = string.format('\n\n## Snippet %d in %s\n%s', snippet_number, file_path, snippet_content)
  local content_file = io.open(tmp_content_file, 'a')
  content_file:write(content)
  content_file:close()

  -- Read the full content file and yank it into the clipboard
  content_file = io.open(tmp_content_file, 'r')
  local full_content = content_file:read '*a'
  content_file:close()
  vim.fn.setreg('+', full_content)

  return snippet_number, #vim.split(snippet_content, '\n')
end

-- Function to get visual selection content
function M.get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get the start and end positions
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, '<')
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, '>')

  local start_line = start_pos[1] - 1 -- Convert to 0-based index
  local start_col = start_pos[2]
  local end_line = end_pos[1] - 1
  local end_col = end_pos[2]

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
  if #lines == 0 then
    return ''
  end

  -- Adjust the first and last lines
  lines[1] = string.sub(lines[1], start_col + 1)
  lines[#lines] = string.sub(lines[#lines], 1, end_col)

  return table.concat(lines, '\n')
end

-- Function to get the next snippet number
function M.get_next_snippet_number()
  local snippet_number = 1
  local content_file = io.open(tmp_content_file, 'r')
  if content_file then
    for line in content_file:lines() do
      local num = line:match '^## Snippet (%d+) in'
      if num then
        num = tonumber(num)
        if num and num >= snippet_number then
          snippet_number = num + 1
        end
      end
    end
    content_file:close()
  end
  return snippet_number
end

-- Function to parse the temporary content file and get entries
function M.get_content_entries()
  local entries = {}
  local content_file = io.open(tmp_content_file, 'r')
  if content_file then
    local lines = {}
    for line in content_file:lines() do
      table.insert(lines, line)
    end
    content_file:close()

    -- Now parse lines to extract entries
    local i = 1
    while i <= #lines do
      local line = lines[i]
      if line:match '^# ' then
        -- It's a file entry
        local file_path = line:sub(3)
        local content_lines = {}
        i = i + 1
        while i <= #lines and not lines[i]:match '^#' and not lines[i]:match '^##' do
          table.insert(content_lines, lines[i])
          i = i + 1
        end
        local line_count = #content_lines
        table.insert(entries, { type = 'file', path = file_path, lines = line_count })
      elseif line:match '^## Snippet (%d+) in (.+)' then
        -- It's a snippet entry
        local snippet_number, file_path = line:match '^## Snippet (%d+) in (.+)'
        snippet_number = tonumber(snippet_number)
        local content_lines = {}
        i = i + 1
        while i <= #lines and not lines[i]:match '^#' and not lines[i]:match '^##' do
          table.insert(content_lines, lines[i])
          i = i + 1
        end
        local line_count = #content_lines
        table.insert(entries, { type = 'snippet', number = snippet_number, path = file_path, lines = line_count })
      else
        -- Other lines, skip
        i = i + 1
      end
    end
  end
  return entries
end

-- Function to clear the temporary file and clear the clipboard
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

  -- Delete the temporary file
  os.remove(tmp_content_file)

  -- Clear the clipboard
  vim.fn.setreg('+', '')

  return lines_cleared
end

return M
