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
	hs.mouse.absolutePosition({ x = 1442, y = 605 })
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
			-- Check for Cmd+S (keyCode 1 is 's')
			if flags.cmd and not flags.shift and not flags.alt and not flags.ctrl and keyCode == 1 then
				hs.mouse.absolutePosition({ x = 2470, y = 644 })
				hs.timer.doAfter(0.2, function()
					forceClick()
				end)
				return true -- Consume the event
			-- Check for Cmd+F (keyCode 3 is 'f')
			elseif flags.cmd and not flags.shift and not flags.alt and not flags.ctrl and keyCode == 3 then
				hs.mouse.absolutePosition({ x = 2494, y = 645 })
				hs.timer.doAfter(0.2, function()
					forceClick()
				end)
				return true -- Consume the event
			-- Check for Ctrl+V (keyCode 9 is 'v')
			elseif flags.ctrl and not flags.shift and not flags.alt and not flags.cmd and keyCode == 9 then
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
hs.hotkey.bind({ "cmd" }, "/", function()
	hs.alert.show("Reloading Hammerspoon...")
	hs.timer.doAfter(0.5, function()
		hs.reload()
	end)
end)

-- Auto-reload Hammerspoon every 60 seconds
autoReloadTimer = hs.timer.doEvery(60, function()
	hs.reload()
end)

-- Reload Sketchybar
hs.hotkey.bind({ "cmd", "shift" }, "b", function()
	hs.task.new("/bin/bash", nil, { "-c", "sketchybar --reload" }):start()
	hs.alert.show("Sketchybar reloaded")
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

-- Toggle between music and pomodoro view (Alt+E)
hs.hotkey.bind({ "alt" }, "E", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh &")
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
