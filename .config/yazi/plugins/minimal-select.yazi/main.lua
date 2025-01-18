local function info(content)
  return ya.notify {
    title = 'minimal-select-and-print',
    content = content,
    timeout = 5,
  }
end

-- Debug helper to print all properties of a table
local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local inspect_files = ya.sync(function()
  local message = 'Selected files:\n\n'
  for _, file in pairs(cx.active.selected) do
    message = message .. 'File properties:\n' .. dump(file) .. '\n\n'
  end
  info(message)
end)

return {
  entry = function()
    inspect_files()
  end,
}
