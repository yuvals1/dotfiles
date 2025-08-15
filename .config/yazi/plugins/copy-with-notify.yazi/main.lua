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

local get_selected_files = ya.sync(function()
  local selected = {}
  for _, u in pairs(cx.active.selected) do
    table.insert(selected, {
      url = tostring(u),
      name = u.name
    })
  end
  return selected
end)

return {
  entry = function(self, job)
    -- Get the mode from job.args
    local mode = job.args and job.args[1] or "path"
    
    -- Get selected files first, fallback to hovered
    local selected_files = get_selected_files()
    local files_to_process = {}
    
    if #selected_files > 0 then
      files_to_process = selected_files
    else
      local hovered = get_hovered()
      if not hovered then
        return info('Copy', 'No item hovered or selected')
      end
      files_to_process = {hovered}
    end
    
    local content_parts = {}
    local title
    
    for _, file in ipairs(files_to_process) do
      local file_content
      
      if mode == "path" then
        file_content = file.url
        title = "Full Path"
      elseif mode == "relative" then
        file_content = get_relative_path(file.url)
        title = "Relative Path"
      elseif mode == "filename" then
        file_content = file.name
        title = "Filename"
      elseif mode == "name_without_ext" then
        file_content = remove_extension(file.name)
        title = "Filename without extension"
      elseif mode == "dirname" then
        file_content = file.url:match("(.*/)")
        if not file_content then
          file_content = "/"
        end
        title = "Directory Path"
      else
        return info('Copy', 'Unknown mode: ' .. mode)
      end
      
      table.insert(content_parts, file_content)
    end
    
    local content = table.concat(content_parts, "\n")
    ya.clipboard(content)
    
    if #files_to_process == 1 then
      info(title, string.format('Copied: %s', content))
    else
      info(title, string.format('Copied %d %s', #files_to_process, title:lower() .. "s"))
    end
  end,
}