--- @desc Deep-filter '.txt' with levels=3 and auto-enter unique dir

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

local function entry()
  -- Apply deep filter for '.txt3' with 5 descendant levels
  ya.emit("filter_do", { ".txt3", deep = true, levels = 5, done = true })
  -- Give the UI a moment to apply the filter before checking uniqueness
  ya.sleep(0.03)

  -- Auto-enter as long as exactly one item remains and it's a directory
  -- Rely on core to carry deep-filter across cd within the root
  for _ = 1, 10 do
    local h = hovered()
    if h.unique and h.is_dir then
      ya.emit("enter", {})
      -- Wait for directory change to be processed (files loaded, hover set)
      ya.sleep(0.03)
    else
      break
    end
  end
end

return { entry = entry }
