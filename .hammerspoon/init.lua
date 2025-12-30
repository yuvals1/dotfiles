-- Hammerspoon configuration for moving mouse cursor to specific coordinates and clicking

-- Alternate fallback click method if needed
function forceClick()
	-- This is a very direct method that should always work
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, hs.mouse.absolutePosition()):post()
	hs.timer.usleep(20000) -- 20ms
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, hs.mouse.absolutePosition()):post()
end



-- Move to specific coordinate and click - Right-center position (alternative keybind)
hs.hotkey.bind({ "ctrl", "shift" }, "v", function()
	hs.mouse.absolutePosition({ x = 100, y = 605 })
	-- Add a delay before clicking
	hs.timer.doAfter(0.2, function()
		forceClick()
	end)
end)

-- Get current mouse position (for debugging)
hs.hotkey.bind({ "cmd", "shift" }, "P", function()
	local pos = hs.mouse.absolutePosition()
	hs.alert.show("Mouse at: " .. math.floor(pos.x) .. "," .. math.floor(pos.y))
end)

-- Chrome-specific keybinds using event tap with auto-restart
local chromeEventtap = nil
local restartAttempts = 0
local maxRestartAttempts = 3

local function createChromeEventtap()
	return hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		local flags = event:getFlags()
		local keyCode = event:getKeyCode()
		local app = hs.application.frontmostApplication()
		
		-- Only process if we're in Chrome
		if app and app:name() == "Google Chrome" then
			-- Check for Ctrl+V (keyCode 9 is 'v')
			if flags.ctrl and not flags.shift and not flags.alt and not flags.cmd and keyCode == 9 then
				hs.mouse.absolutePosition({ x = 1074, y = 605 })
				hs.timer.doAfter(0.2, function()
					forceClick()
				end)
				return true -- Consume the event
			end
		end
		return false -- Let the event pass through for other apps
	end)
end

-- Function to safely restart the event tap
local function restartChromeEventtap()
	if chromeEventtap then
		chromeEventtap:stop()
	end
	
	-- Create new event tap
	chromeEventtap = createChromeEventtap()
	local started = chromeEventtap:start()
	
	if started then
		restartAttempts = 0
		return true
	else
		restartAttempts = restartAttempts + 1
		if restartAttempts <= maxRestartAttempts then
			hs.alert.show("Chrome event tap failed to start, retrying... (" .. restartAttempts .. "/" .. maxRestartAttempts .. ")")
			hs.timer.doAfter(1, restartChromeEventtap)
		else
			hs.alert.show("Chrome event tap failed after " .. maxRestartAttempts .. " attempts. Press Cmd+Shift+R to reload.")
		end
		return false
	end
end

-- Initial start
restartChromeEventtap()



-- Reload Hammerspoon configuration
hs.hotkey.bind({ "cmd", "shift" }, "/", function()
	hs.alert.show("Reloading Hammerspoon...")
	hs.timer.doAfter(0.5, function()
		hs.reload()
	end)
end)

-- Auto-reload Hammerspoon every 60 seconds
autoReloadTimer = hs.timer.doEvery(60, function()
	hs.reload()
end)

-- STOPWATCH KEYBINDINGS
-- Start/stop stopwatch (Alt+N)
hs.hotkey.bind({ "alt" }, "N", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/stopwatch.sh 2>/dev/null &")
end)

-- Cycle to next stopwatch mode (Alt+M)
hs.hotkey.bind({ "alt" }, "M", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/stopwatch.sh next_mode 2>/dev/null &")
end)

-- Navigate history dates (Alt+, for previous, Alt+. for next)
hs.hotkey.bind({ "alt" }, ",", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/history_navigate.sh prev 2>/dev/null &")
end)

hs.hotkey.bind({ "alt" }, ".", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/history_navigate.sh next 2>/dev/null &")
end)

-- Toggle between stopwatch, history, and counting states view (Alt+E)
hs.hotkey.bind({ "alt" }, "E", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh &")
end)

-- COUNTING STATES KEYBINDINGS
-- Cycle to next counting state (Alt+O)
hs.hotkey.bind({ "alt" }, "O", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/counting_states.sh next_state 2>/dev/null &")
end)

-- Select/log current counting state (Alt+U)
hs.hotkey.bind({ "alt" }, "U", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/counting_states.sh select 2>/dev/null &")
end)

-- Chrome detection timer to reload when switching to Chrome
local chromeWasActive = false
local checkInterval = 5  -- Check every 5 seconds

hs.timer.doEvery(checkInterval, function()
	local currentApp = hs.application.frontmostApplication()
	local isChromeActive = currentApp and currentApp:name() == "Google Chrome"
	
	-- If Chrome just became active (wasn't before, but is now)
	if isChromeActive and not chromeWasActive then
		hs.reload()
	end
	
	-- Update our tracking variable
	chromeWasActive = isChromeActive
end)

-- SLEEP KEYBIND
-- Put Mac to sleep (Alt+Cmd+S)
hs.hotkey.bind({ "alt", "cmd" }, "s", function()
	hs.caffeinate.systemSleep()
end)

-- SSH KEEPALIVE (extracted to module)
local keepalive = require("ssh_keepalive")

-- Bind toggle hotkey (Ctrl+Alt+Cmd+L)
keepalive.bindHotkeys({ toggle = { {"ctrl","alt","cmd"}, "L" } })

-- Auto-start if previously enabled
keepalive.startIfEnabled()
