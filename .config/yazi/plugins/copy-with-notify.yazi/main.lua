-- plugins/copy-with-notify.yazi/main.lua

local function info(title, content)
  return ya.notify {
    title = title,
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
    return {
      url = tostring(hovered.url),
      name = hovered.name
    }
  end
  return nil
end)

return {
  entry = function(self, job)
    local hovered = get_hovered()
    if not hovered then
      return info('Copy', 'No item hovered')
    end

    -- Get the mode from job.args
    local mode = job.args and job.args[1] or "path"
    
    -- Debug notification
    -- info("Debug", string.format("Mode: %s, Args: %s", mode, job.args and table.concat(job.args, ", ") or "nil"))
    
    local content, title
    
    if mode == "path" then
      content = hovered.url
      title = "Full Path"
    elseif mode == "relative" then
      content = get_relative_path(hovered.url)
      title = "Relative Path"
    elseif mode == "filename" then
      content = hovered.name
      title = "Filename"
    elseif mode == "name_without_ext" then
      content = remove_extension(hovered.name)
      title = "Filename without extension"
    else
      return info('Copy', 'Unknown mode: ' .. mode)
    end

    ya.clipboard(content)
    info(title, string.format('Copied: %s', content))
  end,
}