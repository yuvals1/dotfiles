-- Hammerspoon configuration for moving mouse cursor to specific coordinates and clicking

-- BASIC MOUSE MOVEMENT AND CLICK FUNCTION
function moveAndClick(x, y)
	-- First move the mouse
	hs.mouse.absolutePosition({ x = x, y = y })

	-- Give time for the move to complete
	hs.timer.usleep(100000) -- 100ms pause

	-- Click directly at current position (most reliable method)
	local currentPosition = hs.mouse.absolutePosition()
	hs.eventtap.leftClick(currentPosition)
end

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

-- Move to specific coordinate and click - Position 1
hs.hotkey.bind({ "cmd", "shift" }, "q", function()
	hs.mouse.absolutePosition({ x = 1377, y = 149 })
	-- Add a delay before clicking
	hs.timer.doAfter(0.2, function()
		forceClick()
	end)
end)


-- Same as Position 3 but works everywhere except Kitty (Cmd+J)
-- local cmdJEventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
-- 	local flags = event:getFlags()
-- 	local keyCode = event:getKeyCode()
--
-- 	-- Check if it's Cmd+J (keyCode 38 is 'j')
-- 	if flags.cmd and not flags.shift and not flags.alt and not flags.ctrl and keyCode == 38 then
-- 		local app = hs.application.frontmostApplication()
-- 		if app:name() ~= "kitty" then
-- 			-- Consume the event and perform our action
-- 			hs.mouse.absolutePosition({ x = 1074, y = 605 })
-- 			hs.timer.doAfter(0.2, function()
-- 				forceClick()
-- 			end)
-- 			return true -- Consume the event
-- 		end
-- 	end
-- 	return false -- Let the event pass through
-- end)
--
-- cmdJEventtap:start()

-- Get current mouse position (for debugging)
hs.hotkey.bind({ "cmd", "shift" }, "P", function()
	local pos = hs.mouse.absolutePosition()
	hs.alert.show("Mouse at: " .. math.floor(pos.x) .. "," .. math.floor(pos.y))
end)

-- For testing: Simple click at current position
hs.hotkey.bind({ "cmd", "shift" }, "C", function()
	forceClick()
	hs.alert.show("Clicked at current position")
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
	hs.reload()
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

-- POMODORO TIMER KEYBINDINGS
-- Toggle work session (Alt+N)
hs.hotkey.bind({ "alt" }, "N", function()
	io.popen("NAME=work /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/pomodoro.sh 2>/dev/null &")
end)

-- Toggle break session (Alt+M)
hs.hotkey.bind({ "alt" }, "M", function()
	io.popen("NAME=break /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/pomodoro.sh 2>/dev/null &")
end)

-- Toggle pause/resume pomodoro timer (Alt+,)
hs.hotkey.bind({ "alt" }, ",", function()
	io.popen("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/pomodoro_pause.sh 2>/dev/null &")
	hs.alert.show("Toggled pause")
end)

-- MUSIC PLAYER KEYBINDINGS (works with both Spotify and YouTube Music)
-- Toggle shuffle (Alt+Y)
hs.hotkey.bind({ "alt" }, "Y", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh shuffle &")
end)

-- Previous track (Alt+U)
hs.hotkey.bind({ "alt" }, "U", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh previous &")
end)

-- Play/Pause (Alt+I)
hs.hotkey.bind({ "alt" }, "I", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh play-pause &")
end)

-- Next track (Alt+O)
hs.hotkey.bind({ "alt" }, "O", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh next &")
end)

-- Seek backward 10 seconds (Alt+Cmd+U)
hs.hotkey.bind({ "alt", "cmd" }, "U", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh seek-backward &")
end)

-- Seek forward 10 seconds (Alt+Cmd+O)
hs.hotkey.bind({ "alt", "cmd" }, "O", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh seek-forward &")
end)

-- Note: Seek commands only work when spotify-player is the active device
-- These won't control iPhone/other device playback

-- Toggle repeat (Alt+P)
hs.hotkey.bind({ "alt" }, "P", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh repeat &")
end)

-- Add current track to playlist (Alt+T)
hs.hotkey.bind({ "alt" }, "T", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh add-to-playlist &")
end)

-- Toggle between music and pomodoro view (Alt+E)
hs.hotkey.bind({ "alt" }, "E", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh &")
	-- hs.alert.show("Toggled center view")
end)

-- Cycle through Spotify radio modes (Alt+R)
hs.hotkey.bind({ "alt" }, "R", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh radio_toggle &")
end)

-- Go to top tracks playlist (Alt+G)
hs.hotkey.bind({ "alt" }, "G", function()
	os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh go-to-top-tracks &")
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

-- AIRPODS CONNECTION
-- Function to toggle between AirPods Pro and MacBook Speakers
function toggleAudioOutput()
	local airpodsAddress = "38:88:A4:F0:56:19"
	
	-- First check current audio output
	hs.task.new("/usr/local/bin/SwitchAudioSource", function(exitCode, stdOut, stdErr)
		local currentDevice = stdOut:gsub("\n", "")
		
		if currentDevice:match("AirPods") then
			-- Currently on AirPods, switch to speakers
			hs.task.new("/usr/local/bin/SwitchAudioSource", function(exitCode2, stdOut2, stdErr2)
				if exitCode2 == 0 then
					hs.alert.show("Switched to MacBook Speakers")
				end
			end, {"-s", "MacBook Pro Speakers"}):start()
		else
			-- Currently on speakers (or other device), switch to AirPods
			-- First disconnect to wake up AirPods
			hs.task.new("/usr/local/bin/blueutil", function(exitCode2, stdOut2, stdErr2)
				-- Reconnect after brief pause
				hs.timer.doAfter(0.5, function()
					hs.task.new("/usr/local/bin/blueutil", function(exitCode3, stdOut3, stdErr3)
						-- Wait for AirPods to become available as audio device
						hs.timer.doAfter(2, function()
							-- Switch to AirPods using grep to find them
							hs.task.new("/bin/bash", function(exitCode4, stdOut4, stdErr4)
								if exitCode4 == 0 and stdOut4:match("AirPods Pro") then
									hs.alert.show("Switched to AirPods Pro")
								else
									hs.alert.show("Failed to connect AirPods Pro")
								end
							end, {"-c", 'DEVICE=$(SwitchAudioSource -a -t output | grep -i airpods | head -1); SwitchAudioSource -s "$DEVICE" 2>&1'}):start()
						end)
					end, {"--connect", airpodsAddress}):start()
				end)
			end, {"--disconnect", airpodsAddress}):start()
		end
	end, {"-c"}):start()
end

-- Toggle between AirPods Pro and MacBook Speakers (Alt+A)
hs.hotkey.bind({ "alt" }, "A", function()
	toggleAudioOutput()
end)

-- Alert to show Hammerspoon config loaded successfully
-- hs.alert.show("Hammerspoon config loaded with click functionality")

-- SPOTIFY DAEMON CONTROL
-- Toggle both spotify.sh and spotify_player daemons (Alt+S)
hs.hotkey.bind({ "alt" }, "s", function()
	-- Check if either daemon is running
	local checkTask = hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
		if stdOut and stdOut:match("spotify") then
			-- Daemons are running, kill both
			os.execute("pkill -f spotify.sh")
			os.execute("pkill -f spotify_player")
			-- Show "Spotify Stopped" state (justified as shutdown notification)
			os.execute([[
				sketchybar --set spotify.anchor drawing=on icon=":spotify:" label="Spotify Stopped" \
					--set spotify.context drawing=off \
					--set spotify.menubar_controls drawing=off \
					--set spotify.progress drawing=off \
					--set spotify.artwork drawing=off
			]])
			hs.alert.show("Spotify daemons stopped")
		else
			-- Daemons are not running, start both
			-- Start spotify_player daemon first
			os.execute("/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player -d &")
			-- Small delay to let spotify_player initialize
			hs.timer.doAfter(0.5, function()
				-- Then start the UI daemon
				os.execute("/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify.sh &")
			end)
			hs.alert.show("Spotify daemons started")
		end
	end, {"-c", "ps aux | grep -E 'spotify\\.sh|spotify_player' | grep -v grep"})
	checkTask:start()
end)

-- SLEEP KEYBIND
-- Put Mac to sleep (Alt+Cmd+S)
hs.hotkey.bind({ "alt", "cmd" }, "s", function()
	hs.caffeinate.systemSleep()
end)
