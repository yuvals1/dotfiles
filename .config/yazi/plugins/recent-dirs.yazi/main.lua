-- recent-dirs.yazi
-- Tracks last 5 unique directories per tab and provides an fzf UI to jump

local function notify(title, content, level)
  ya.notify { title = title or 'Recent Dirs', content = content or '', timeout = 3, level = level or 'info' }
end

-- Helper to get current tab index and per-tab history state
local get_tab_and_history = ya.sync(function(state)
  return cx.tabs.idx, state.tabhist
end)

-- Ensure per-tab list exists (utility to be called from setup only)
local ensure_list = function(tabhist, tab)
  if not tabhist[tab] then tabhist[tab] = {} end
  return tabhist[tab]
end

return {
  -- Subscribe to cd events; keep last 5 unique directories per tab
  setup = function(state)
    state.tabhist = state.tabhist or {}

    ps.sub('cd', function(body)
      local tab = body.tab or cx.tabs.idx
      local cwd = tostring(cx.active.current.cwd)

      local tabhist = state.tabhist
      local list = ensure_list(tabhist, tab)

      -- Remove any existing occurrence of this cwd
      for i = #list, 1, -1 do
        if list[i] == cwd then table.remove(list, i) end
      end
      -- Add to front
      table.insert(list, 1, cwd)
      -- Cap at 5 items
      while #list > 5 do table.remove(list) end
    end)
  end,

  -- For step 1: Show recent list via notification (no fzf yet)
  entry = function()
    local tab, hist = get_tab_and_history()
    hist = hist or {}
    local list = hist[tab] or {}

    if #list == 0 then
      return notify('Recent Dirs', 'No directory history yet', 'warn')
    end

    notify('Recent Dirs', table.concat(list, '\n'), 'info')
  end,
}
