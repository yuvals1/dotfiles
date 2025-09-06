--- @desc Deep-filter '.txt' with levels=3

local function entry()
  -- Apply non-interactive deep filter for '.txt' with 3 descendant levels
  -- Semantics: L=3 includes children, grandchildren, and great-grandchildren
  ya.emit("filter_do", { ".txt", deep = true, levels = 3, done = true })
end

return { entry = entry }

