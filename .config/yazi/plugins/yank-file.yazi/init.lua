local function info(content)
  return ya.notify {
    title = 'Yank Content',
    content = content,
    timeout = 5,
  }
end

local hovered_url = ya.sync(function()
  local h = cx.active.current.hovered
  return h and h.url
end)

return {
  entry = function()
    local file_url = hovered_url()
    if not file_url then
      return info 'No file hovered'
    end

    local output, err = Command('cat'):arg(tostring(file_url)):output()
    if not output then
      return info('Failed to read file, error: ' .. err)
    end

    ya.clipboard(output.stdout)
    info 'File content copied to clipboard'
  end,
}
