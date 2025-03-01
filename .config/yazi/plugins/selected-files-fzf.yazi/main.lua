local function fail(s, ...)
  ya.notify { title = 'Selected-Fzf', content = string.format(s, ...), timeout = 5, level = 'error' }
end

-- Get selected files
local get_selected = ya.sync(function()
  local files = {}
  for _, file in pairs(cx.active.selected) do
    table.insert(files, tostring(file))
  end
  return files
end)

-- Check if a path is a directory using Command
local function is_directory(path)
  local child, err = Command('test'):args({ '-d', path }):stdout(Command.PIPED):stderr(Command.PIPED):spawn()

  if not child then
    return false
  end

  local output = child:wait_with_output()
  return output and output.status.success
end

-- Get line count or file type indicator
local function get_file_info(path)
  -- First check if it's a directory
  if is_directory(path) then
    return 'DIR'
  end

  -- Try to open the file with a time limit by using Command
  local child, err = Command('wc'):args({ '-l', path }):stdout(Command.PIPED):stderr(Command.PIPED):spawn()

  if not child then
    return 'N/A'
  end

  local output = child:wait_with_output()
  if not output or not output.status.success then
    return 'N/A'
  end

  -- Extract line count from wc output
  local count = tonumber(output.stdout:match '^%s*(%d+)')
  if not count then
    return 'N/A'
  end

  -- Format the output
  if count == 0 then
    return '0L'
  elseif count < 1000 then
    return count .. 'L'
  else
    -- Format thousands with K
    return string.format('%.1fK', count / 1000) .. 'L'
  end
end

local function entry()
  local _permit = ya.hide()

  -- Get selected files
  local files = get_selected()
  if #files == 0 then
    return fail 'No files selected'
  end

  -- Create formatted entries with file info
  local fzf_entries = {}

  for _, filepath in ipairs(files) do
    local filename = filepath:match '([^/]+)$' or filepath

    -- Get file info (line count or DIR)
    local file_info = get_file_info(filepath)

    -- Use tab as delimiter - it's standard and works well with FZF
    local entry = string.format('%s (%s)\t%s', filename, file_info, filepath)
    table.insert(fzf_entries, entry)
  end

  -- Create fzf command
  local child, err = Command('fzf')
    :args({
      '--delimiter',
      '\t', -- Use tab as delimiter - standard for FZF
      '--with-nth',
      '1', -- Show only the first part (filename with line count)
      '--preview',
      'echo "Full path: {2}\n---" && if [ -d {2} ]; then ls -la {2}; else bat --color=always {2} || cat {2} || echo "Cannot display content"; fi', -- Show directory contents or file preview
      '--height',
      '100%',
      '--layout',
      'reverse',
      '--border',
    })
    :stdin(Command.PIPED)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not child then
    return fail('Failed to start `fzf`, error: ' .. err)
  end

  -- Write formatted entries to fzf
  local input = table.concat(fzf_entries, '\n')
  child:write_all(input)
  child:flush()

  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read `fzf` output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('`fzf` exited with error code %s', output.status.code)
  end

  local selected_entry = output.stdout:gsub('\n$', '')
  if selected_entry ~= '' then
    -- Extract the actual filepath from our formatted entry
    local target = selected_entry:match '\t(.+)$'
    if target then
      ya.manager_emit('reveal', { target })
    else
      -- Fallback to the original entry if pattern match fails
      ya.manager_emit('reveal', { selected_entry })
    end
  end
end

return { entry = entry }
