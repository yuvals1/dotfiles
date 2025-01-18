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

local function entry()
  local _permit = ya.hide()

  -- Get selected files
  local files = get_selected()
  if #files == 0 then
    return fail 'No files selected'
  end

  -- Same fzf command but with PIPED stdin
  local child, err = Command('fzf'):stdin(Command.PIPED):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

  if not child then
    return fail('Failed to start `fzf`, error: ' .. err)
  end

  -- Write selected files to fzf
  local input = table.concat(files, '\n')
  child:write_all(input)
  child:flush()

  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read `fzf` output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('`fzf` exited with error code %s', output.status.code)
  end

  local target = output.stdout:gsub('\n$', '')
  if target ~= '' then
    ya.manager_emit(target:find('[/\\]$' and 'cd' or 'reveal', { target }))
  end
end

return { entry = entry }
