local folders = '~/dev-projects/test-fzf-folders/a ~/dev-projects/test-fzf-folders/b'

local state = ya.sync(function()
  return cx.active.current.cwd
end)

local function fail(s, ...)
  ya.notify { title = 'Fzf', content = string.format(s, ...), timeout = 5, level = 'error' }
end

local function entry()
  local _permit = ya.hide()
  local cwd = tostring(state())

  -- Store find results in a variable first
  local find_cmd = [[
    result=$(for dir in ]] .. folders .. [[; do
      (cd "$dir" && find . -type f | sed 's|^./||')
    done)
    
    if [ -n "$result" ]; then
      echo "$result" | fzf --preview "bat {}"
    else
      echo "No files found" >&2
      exit 1
    fi
  ]]

  local child, err = Command('sh'):args({ '-c', find_cmd }):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

  if not child then
    return fail('Failed to start command, error: ' .. err)
  end

  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('Command exited with error code %s', output.status.code)
  end

  local target = output.stdout:gsub('\n$', '')
  if target ~= '' then
    ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
  end
end

return { entry = entry }
