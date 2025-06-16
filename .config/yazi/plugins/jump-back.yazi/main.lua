-- Jump directly to the previous directory in the current tab

local get_current_tab_idx = ya.sync(function()
  return cx.tabs.idx
end)

local get_state = ya.sync(function(state, key)
  return state[key]
end)

return {
  setup = function(state)
    -- Subscribe to cd events to track directory history
    ps.sub("cd", function(body)
      local tab = body.tab
      local cwd = tostring(cx.active.current.cwd)
      local tabhist = state.tabhist or {}
      
      if not tabhist[tab] then
        tabhist[tab] = { cwd }
      else
        tabhist[tab] = { cwd, tabhist[tab][1] }
      end
      state.tabhist = tabhist
    end)
  end,
  
  entry = function(self)
    local tab = get_current_tab_idx()
    local tabhist = get_state("tabhist")
    
    if tabhist and tabhist[tab] and tabhist[tab][2] then
      local previous_dir = tabhist[tab][2]
      ya.emit("cd", { previous_dir })
      ya.notify({
        title = "Jump Back",
        content = "Jumped to: " .. previous_dir,
        timeout = 1,
        level = "info"
      })
    else
      ya.notify({
        title = "Jump Back", 
        content = "No previous directory",
        timeout = 2,
        level = "warn"
      })
    end
  end,
}