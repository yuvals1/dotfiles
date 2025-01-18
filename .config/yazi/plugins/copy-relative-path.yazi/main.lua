-- plugins/copy-relative-path.yazi/init.lua

local function info(content)
  return ya.notify {
    title = 'Relative Path',
    content = content,
    timeout = 3,
  }
end

local function get_home_path()
  return os.getenv 'HOME' or os.getenv 'USERPROFILE'
end

local function get_relative_path(path)
  local home = get_home_path()
  if path:sub(1, #home) == home then
    return '~' .. path:sub(#home + 1)
  end
  return path
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
    local relative_path = get_relative_path(path)

    ya.clipboard(relative_path)
    info(string.format('Copied relative path: %s', relative_path))
  end,
}
