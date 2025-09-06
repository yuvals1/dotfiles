-- Jump between files tagged with any macOS tag
-- Uses core tags via file:tags(); scans only the visible window

-- Snapshot needed info from the current view
local get_jump_info = ya.sync(function()
  local folder = cx.active.current
  local tagged_positions = {}

  for i, file in ipairs(folder.window) do
    local tags = file:tags()
    if tags and #tags > 0 then
      tagged_positions[#tagged_positions + 1] = i
    end
  end

  return {
    positions = tagged_positions,
    cursor = folder.cursor,
    offset = folder.offset,
  }
end)

local function entry(_, job)
  local action = job.args[1]
  assert(action == "next" or action == "prev", "Invalid action: use 'next' or 'prev'")

  local info = get_jump_info()
  if #info.positions == 0 then
    ya.notify { title = "Tag Jump", content = "No tagged files found in visible window" }
    return
  end

  local current = info.cursor - info.offset + 1 -- 1-based within window
  local target

  if action == "next" then
    for _, pos in ipairs(info.positions) do
      if pos > current then target = pos; break end
    end
    target = target or info.positions[1]
  else -- prev
    for i = #info.positions, 1, -1 do
      local pos = info.positions[i]
      if pos < current then target = pos; break end
    end
    target = target or info.positions[#info.positions]
  end

  -- Simple relative jump within the window
  local jump = target - current
  if jump ~= 0 then
    ya.manager_emit("arrow", { jump })
  end
end

return { entry = entry }
