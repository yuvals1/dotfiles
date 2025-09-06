--- Deep tag filter helper
--- Usage:
---   plugin deep-tag <tag> [levels]
--- Examples:
---   plugin deep-tag blue        -- deep filter Blue-tagged items, levels=2 (default)
---   plugin deep-tag red 3       -- deep filter Red-tagged items, levels=3
---   plugin deep-tag clear       -- clear filter

-- Helper to read hovered info and uniqueness
local hovered = ya.sync(function()
  local h = cx.active.current.hovered
  if not h then
    return { is_dir = false, unique = false }
  end
  return {
    url = h.url,
    is_dir = h.cha.is_dir,
    unique = #cx.active.current.files == 1,
  }
end)

local function titlecase(s)
  if not s or s == '' then return s end
  return s:sub(1,1):upper() .. s:sub(2):lower()
end

local function entry(_, job)
  local arg = (job.args[1] or ''):lower()
  if arg == '' or arg == 'clear' or arg == 'off' or arg == 'none' then
    ya.emit('filter_do', { '', deep = false, done = true })
    return
  end

  local levels = tonumber(job.args[2] or '') or 2
  -- Accept comma-separated tags
  local tags = {}
  for t in tostring(arg):gmatch('[^,]+') do
    local clean = t:match('^%s*(.-)%s*$')
    if #clean > 0 then table.insert(tags, titlecase(clean)) end
  end
  if #tags == 0 then return end

  ya.emit('filter_do', { tags = table.concat(tags, ','), deep = true, levels = levels, done = true })

  -- Auto-enter unique directory chains (like deep-txt)
  ya.sleep(0.03)
  for _ = 1, 10 do
    local h = hovered()
    if h.unique and h.is_dir then
      ya.emit('enter', {})
      ya.sleep(0.03)
    else
      break
    end
  end
end

return { entry = entry }
