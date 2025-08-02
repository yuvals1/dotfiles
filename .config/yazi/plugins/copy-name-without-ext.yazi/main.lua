-- plugins/copy-name-without-ext.yazi/main.lua

local function info(content)
  return ya.notify {
    title = 'Filename without extension',
    content = content,
    timeout = 3,
  }
end

local function remove_extension(filename)
  local lastDot = filename:match(".*()%.")
  if lastDot then
    return filename:sub(1, lastDot - 1)
  end
  return filename
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

    local name_without_ext = remove_extension(filename)
    ya.clipboard(name_without_ext)
    info(string.format('Copied: %s', name_without_ext))
  end,
}