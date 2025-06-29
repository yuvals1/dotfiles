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

-- CLIPBOARD SPEAKING FUNCTIONS
-- Variable to store the speaking task
local speakingTask = nil

-- Helper function to get text from tmux selection or clipboard
local function getTextToSpeak()
	-- Check if we're in a terminal that might have tmux
	local app = hs.application.frontmostApplication()
	if app and (app:name() == "kitty" or app:name() == "Terminal" or app:name() == "iTerm2") then
		-- Try to copy tmux selection without clearing it
		hs.task.new("/bin/bash", nil, { "-c", "tmux send-keys -X copy-pipe-no-clear 'pbcopy' 2>/dev/null" }):start()
		-- Small delay to ensure clipboard is updated
		hs.timer.usleep(50000) -- 50ms
	end
	return hs.pasteboard.getContents()
end

-- Speak clipboard contents (normal speed - 175 wpm)
hs.hotkey.bind({ "cmd", "shift" }, "a", function()
	-- Kill any existing speech first
	if speakingTask then
		speakingTask:terminate()
	end

	local text = getTextToSpeak()
	if text and text ~= "" then
		-- Start new speech
		speakingTask = hs.task.new("/bin/bash", nil, { "-c", "pbpaste | say -r 175" })
		speakingTask:start()
		hs.alert.show("Speaking (normal)...")
	else
		hs.alert.show("No text to speak")
	end
end)

-- Speak clipboard contents (fast speed - 200 wpm)
hs.hotkey.bind({ "cmd", "shift" }, "s", function()
	-- Kill any existing speech first
	if speakingTask then
		speakingTask:terminate()
	end

	local text = getTextToSpeak()
	if text and text ~= "" then
		-- Start new speech at 200 wpm
		speakingTask = hs.task.new("/bin/bash", nil, { "-c", "pbpaste | say -r 200" })
		speakingTask:start()
		hs.alert.show("Speaking (fast)...")
	else
		hs.alert.show("No text to speak")
	end
end)

-- Speak clipboard contents (faster speed - 220 wpm)
hs.hotkey.bind({ "cmd", "shift" }, "d", function()
	-- Kill any existing speech first
	if speakingTask then
		speakingTask:terminate()
	end

	local text = getTextToSpeak()
	if text and text ~= "" then
		-- Start new speech at 220 wpm
		speakingTask = hs.task.new("/bin/bash", nil, { "-c", "pbpaste | say -r 220" })
		speakingTask:start()
		hs.alert.show("Speaking (faster)...")
	else
		hs.alert.show("No text to speak")
	end
end)

-- Speak clipboard contents (fastest speed - 250 wpm)
hs.hotkey.bind({ "cmd", "shift" }, "f", function()
	-- Kill any existing speech first
	if speakingTask then
		speakingTask:terminate()
	end

	local text = getTextToSpeak()
	if text and text ~= "" then
		-- Start new speech at 250 wpm
		speakingTask = hs.task.new("/bin/bash", nil, { "-c", "pbpaste | say -r 250" })
		speakingTask:start()
		hs.alert.show("Speaking (fastest)...")
	else
		hs.alert.show("No text to speak")
	end
end)

-- Stop speaking
hs.hotkey.bind({ "cmd", "shift" }, "x", function()
	if speakingTask then
		speakingTask:terminate()
		speakingTask = nil
	end
	-- Also use killall as backup
	hs.task.new("/bin/bash", nil, { "-c", "killall say" }):start()
	hs.alert.show("Stopped speaking")
end)

-- Move to specific coordinate and click - Position 2 (alternative keybind)
hs.hotkey.bind({ "cmd" }, "g", function()
	hs.mouse.absolutePosition({ x = 1074, y = 605 })
	-- Add a delay before clicking
	hs.timer.doAfter(0.2, function()
		forceClick()
	end)
end)

-- Move to specific coordinate and click - Position 3 (alternative keybind)
hs.hotkey.bind({ "cmd" }, "/", function()
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

-- Move to specific coordinate and click - Position 2
hs.hotkey.bind({ "cmd", "shift" }, "w", function()
	hs.mouse.absolutePosition({ x = 1074, y = 605 })
	-- Add a delay before clicking
	hs.timer.doAfter(0.2, function()
		forceClick()
	end)
end)

-- Move to specific coordinate and click - Position 3
hs.hotkey.bind({ "cmd", "shift" }, "e", function()
	hs.mouse.absolutePosition({ x = 1442, y = 605 })
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
-- Alert to show Hammerspoon config loaded successfully
hs.alert.show("Hammerspoon config loaded with click functionality and TTS")
