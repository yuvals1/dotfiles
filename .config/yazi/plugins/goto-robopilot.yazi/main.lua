-- Navigate to the robopilot directory, trying common locations

local function dir_exists(path)
  -- Portable check using the shell; returns truthy if directory exists
  local cmd = string.format("test -d %q > /dev/null 2>&1", path)
  return os.execute(cmd) and true or false
end

local function entry()
  local home = os.getenv("HOME") or ""
  local candidates = {
    home .. "/dev/robopilot",
    home .. "/robopilot",
  }

  for _, path in ipairs(candidates) do
    if dir_exists(path) then
      ya.manager_emit("cd", { path })
      return
    end
  end

  ya.notify({
    title = "Goto Robopilot",
    content = "robopilot directory not found in ~/dev or ~/",
    timeout = 3,
    level = "error",
  })
end

return { entry = entry }
