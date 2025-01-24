local M = {}

function M:render(file)
  -- Get file info
  local size = ya.readable_size(file.metadata.len)
  local perms = file.metadata.permissions

  -- Return the formatted string
  return string.format('%s | %s', size, perms)
end

return M
