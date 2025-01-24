local function read_bookmarks()
  local home = os.getenv 'HOME'
  local bookmark_file = home .. '/.config/yazi/bookmark'
  local paths = {}

  local file = io.open(bookmark_file, 'r')
  if not file then
    ya.notify { title = 'FZF', content = 'Could not open bookmark file', level = 'error' }
    return {}
  end

  for line in file:lines() do
    local _, path = line:match '([^\t]+)\t([^\t]+)'
    if path then
      -- Remove trailing slash if exists
      path = path:gsub('/$', '')
      paths[#paths + 1] = path
    end
  end
  file:close()

  return paths
end

local state = ya.sync(function()
  return cx.active.current.cwd
end)

local function fail(s, ...)
  ya.notify { title = 'Fzf', content = string.format(s, ...), timeout = 5, level = 'error' }
end

local function entry()
  local _permit = ya.hide()
  local cwd = tostring(state())
  local bookmarked_paths = read_bookmarks()

  -- Create a command that finds files and shows them relative to their bookmark paths
  local find_commands = {}
  for _, bookmark in ipairs(bookmarked_paths) do
    -- For each bookmark, find files and prefix output with bookmark name
    table.insert(find_commands, string.format("cd '%s' && find . -type f -print | sed 's|^\\./||' | sed 's|^|%s:/|'", bookmark, bookmark))
  end

  -- Combine all commands and pipe to fzf
  local full_cmd = table.concat(find_commands, '; ') .. ' | fzf --with-nth=2.. --delimiter=: ' .. "--preview 'ls -l $(echo {} | cut -d: -f1)/{}'"

  local child, err = Command('sh'):args({ '-c', full_cmd }):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

  if not child then
    return fail('Failed to start `fzf`, error: ' .. err)
  end

  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read `fzf` output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('`fzf` exited with error code %s', output.status.code)
  end

  -- Process the selected path
  local target = output.stdout:gsub('\n$', '')
  if target ~= '' then
    -- Extract full path from the selection
    local base_path, rel_path = target:match '^(.-):/(.*)'
    if base_path and rel_path then
      target = base_path .. '/' .. rel_path
    end
    ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
  end
end

return { entry = entry }
