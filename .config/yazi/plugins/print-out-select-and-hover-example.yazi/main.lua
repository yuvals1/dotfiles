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
  -- Log current hovered file for debugging
  local hovered = cx.active.current.hovered
  if hovered then
    info('Hovered file properties:\n' .. dump(hovered))
    info('Hovered name: ' .. tostring(hovered.name))
    info('Hovered url: ' .. tostring(hovered.url))
  end

  -- Log selected files
  for _, file in pairs(cx.active.selected) do
    info('Selected file properties:\n' .. dump(file))
  end
end)

return {
  entry = function()
    inspect_files()
  end,
}
