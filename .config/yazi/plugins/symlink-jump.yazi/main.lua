-- plugins/symlink-jump.yazi/main.lua

local function info(title, content)
  return ya.notify {
    title = title,
    content = content,
    timeout = 3,
  }
end

local get_hovered = ya.sync(function()
  local hovered = cx.active.current.hovered
  if hovered then
    return tostring(hovered.url)
  end
  return nil
end)

return {
  entry = function(self, job)
    local hovered_path = get_hovered()
    if not hovered_path then
      return info('Symlink Jump', 'No file hovered')
    end
    
    -- Use readlink to get the target
    local handle = io.popen('readlink -f "' .. hovered_path .. '" 2>/dev/null')
    local target = handle:read("*a")
    handle:close()
    
    if target and target ~= "" then
      target = target:gsub("%s+$", "") -- trim whitespace
      if target ~= hovered_path then
        -- Check if target is a file or directory and navigate
        ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
        info('Jumped to', target)
      else
        info('Not a symlink', hovered_path)
      end
    else
      info('Error', 'Could not read symlink')
    end
  end,
}