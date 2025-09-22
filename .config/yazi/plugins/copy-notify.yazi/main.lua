-- plugins/copy-notify.yazi/main.lua

local function notify(title, content)
  ya.notify {
    title = title,
    content = content,
    timeout = 3,
  }
end

local function get_home_path()
  return os.getenv "HOME" or os.getenv "USERPROFILE" or ""
end

local function to_relative(path)
  local home = get_home_path()
  if home ~= "" and path:sub(1, #home) == home then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

local descriptors = {
  path = {
    title = "Full Path",
    plural = "paths",
    format = function(file)
      return file.url
    end,
  },
  dirname = {
    title = "Directory Path",
    plural = "directory paths",
    format = function(file)
      local dir = file.url:match("(.*/)")
      return dir or file.url
    end,
  },
  filename = {
    title = "Filename",
    plural = "filenames",
    format = function(file)
      return file.name or file.url
    end,
  },
  name_without_ext = {
    title = "Filename without extension",
    plural = "filename stems",
    format = function(file)
      local name = file.name or ""
      local last_dot = name:match(".*()%.")
      return last_dot and name:sub(1, last_dot - 1) or name
    end,
  },
  relative = {
    title = "Relative Path",
    plural = "relative paths",
    copy = true,
    format = function(file)
      return to_relative(file.url)
    end,
  },
}

local get_hovered = ya.sync(function()
  local hovered = cx.active.current.hovered
  if hovered then
    return {
      url = tostring(hovered.url),
      name = hovered.name,
    }
  end
  return nil
end)

local get_selected = ya.sync(function()
  local selected = {}
  for _, u in pairs(cx.active.selected) do
    selected[#selected + 1] = {
      url = tostring(u),
      name = u.name,
    }
  end
  return selected
end)

return {
  entry = function(_, job)
    local mode = job.args and job.args[1] or "path"
    local desc = descriptors[mode] or descriptors.path

    local selected = get_selected()
    local targets = selected

    if #targets == 0 then
      local hovered = get_hovered()
      if hovered then
        targets = { hovered }
      end
    end

    if #targets == 0 then
      notify(desc.title, "Nothing to copy")
      return
    end

    local values = {}
    for _, file in ipairs(targets) do
      values[#values + 1] = desc.format(file) or ""
    end

    if desc.copy then
      ya.clipboard(table.concat(values, "\n"))
    end

    if #targets == 1 then
      local value = values[1]
      if value == "" then
        value = desc.title
      end
      notify(desc.title, string.format("Copied: %s", value))
    else
      notify(desc.title, string.format("Copied %d %s", #targets, desc.plural))
    end
  end,
}
