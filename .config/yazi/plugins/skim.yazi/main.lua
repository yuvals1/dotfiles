local state = ya.sync(function()
  return cx.active.current.cwd
end)
local function fail(s, ...)
  ya.notify { title = 'Skim', content = string.format(s, ...), timeout = 5, level = 'error' }
end
local function entry()
  local _permit = ya.hide()
  local cwd = tostring(state())
  -- Just replace 'fzf' with 'sk' (skim's executable)
  local child, err = Command('sk'):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
  if not child then
    return fail('Failed to start `sk`, error: ' .. err)
  end
  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read `sk` output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('`sk` exited with error code %s', output.status.code)
  end
  local target = output.stdout:gsub('\n$', '')
  if target ~= '' then
    ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
  end
end
return { entry = entry }
