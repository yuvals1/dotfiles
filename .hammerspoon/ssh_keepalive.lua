-- ssh_keepalive.lua
-- Simple SSH keepalive module for Hammerspoon

local M = {}

-- Public configuration
M.interval = 10
M.terminalApps = {
  Terminal = true,
  iTerm = true,
  iTerm2 = true,
  Alacritty = true,
  WezTerm = true,
  kitty = true,
  Warp = true,
  Ghostty = true,
}

-- Internal state
local timer = nil

local function frontAppName()
  local app = hs.application.frontmostApplication()
  return app and app:name() or ""
end

local function isTerminalLike(appName)
  return M.terminalApps[appName] == true
end

local function tick()
  local name = frontAppName()
  if not isTerminalLike(name) then return end
  -- Use keyStroke for reliability; some setups drop keyStrokes()
  hs.eventtap.keyStroke({}, "a", 0)
end

function M.isEnabled()
  return timer ~= nil
end

function M.start()
  if timer then return end
  timer = hs.timer.doEvery(M.interval, tick)
  tick()
  hs.settings.set("sshKeepaliveEnabled", true)
  local secure = (hs.eventtap.isSecureInputEnabled and hs.eventtap.isSecureInputEnabled()) and " (Secure Input ON)" or ""
  hs.alert("SSH keepalive: ON (" .. tostring(M.interval) .. "s)" .. secure)
end

function M.stop()
  if timer then timer:stop(); timer = nil end
  hs.settings.set("sshKeepaliveEnabled", false)
  hs.alert("SSH keepalive: OFF")
end

function M.toggle()
  if M.isEnabled() then M.stop() else M.start() end
end

-- Bind a toggle hotkey. Example:
-- keepalive.bindHotkeys({ toggle = { {"ctrl","alt","cmd"}, "L" } })
function M.bindHotkeys(mapping)
  if not mapping or not mapping.toggle then return end
  local mods, key = mapping.toggle[1], mapping.toggle[2]
  hs.hotkey.bind(mods, key, M.toggle)
end

-- Start if it was enabled previously (persists across reloads)
function M.startIfEnabled()
  if hs.settings.get("sshKeepaliveEnabled") then M.start() end
end

return M

