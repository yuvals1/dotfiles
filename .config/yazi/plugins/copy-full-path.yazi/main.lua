-- plugins/copy-full-path.yazi/main.lua

local function info(content)
  return ya.notify {
    title = 'Full Path',
    content = content,
    timeout = 3,
  }
end

local get_hovered = ya.sync(function()
  local hovered = cx.active.current.hovered
  if hovered then
    return hovered.url
  end
  return nil
end)

return {
  entry = function()
    local hovered_path = get_hovered()
    if not hovered_path then
      return info 'No item hovered'
    end

    local path = tostring(hovered_path)
    ya.clipboard(path)
    info(string.format('Copied full path: %s', path))
  end,
}