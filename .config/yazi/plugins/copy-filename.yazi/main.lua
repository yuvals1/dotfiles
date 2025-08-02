-- plugins/copy-filename.yazi/main.lua

local function info(content)
  return ya.notify {
    title = 'Filename',
    content = content,
    timeout = 3,
  }
end

local get_hovered = ya.sync(function()
  local hovered = cx.active.current.hovered
  if hovered then
    return hovered.name
  end
  return nil
end)

return {
  entry = function()
    local filename = get_hovered()
    if not filename then
      return info 'No item hovered'
    end

    ya.clipboard(filename)
    info(string.format('Copied filename: %s', filename))
  end,
}