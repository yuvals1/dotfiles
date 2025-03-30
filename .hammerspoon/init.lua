-- Hammerspoon configuration for moving mouse cursor to specific coordinates

-- BASIC MOUSE MOVEMENT FUNCTION
-- Move mouse to specific x,y coordinates
function moveMouseToPosition(x, y)
	hs.mouse.absolutePosition({ x = x, y = y })
end

-- KEYMAP CONFIGURATION
-- Define keyboard shortcuts to move mouse to preset positions

-- Option 1: Move mouse to specific screen positions with hotkeys
-- Example: Move to center of primary screen
hs.hotkey.bind({ "cmd", "shift" }, "C", function()
	local screen = hs.screen.primaryScreen()
	local screenRect = screen:frame()
	local centerX = screenRect.x + screenRect.w / 2
	local centerY = screenRect.y + screenRect.h / 2

	moveMouseToPosition(centerX, centerY)
end)

-- Example: Move to top-left corner
hs.hotkey.bind({ "cmd", "shift" }, "1", function()
	local screen = hs.screen.primaryScreen()
	local screenRect = screen:frame()

	moveMouseToPosition(screenRect.x, screenRect.y)
end)

-- Example: Move to top-right corner
hs.hotkey.bind({ "cmd", "shift" }, "2", function()
	local screen = hs.screen.primaryScreen()
	local screenRect = screen:frame()

	moveMouseToPosition(screenRect.x + screenRect.w, screenRect.y)
end)

-- Option 2: Create a modal hotkey for dynamic mouse positioning
mousePositionMode = hs.hotkey.modal.new({ "cmd", "shift" }, "M")

-- Press Escape to exit mode
mousePositionMode:bind({}, "escape", function()
	mousePositionMode:exit()
end)

-- Function to handle coordinate movement
function moveMouseToCoordinates()
	-- Create a small dialog to input coordinates
	local button, coordinates = hs.dialog.textPrompt("Move Mouse", "Enter coordinates as 'x,y':", "", "Move", "Cancel")

	if button == "Move" then
		-- Parse the x,y coordinates
		local x, y = coordinates:match("(%d+),(%d+)")

		if x and y then
			x = tonumber(x)
			y = tonumber(y)
			moveMouseToPosition(x, y)
		else
			hs.alert.show("Invalid coordinates format. Use 'x,y'")
		end
	end

	mousePositionMode:exit()
end

-- In position mode, press 'p' to enter coordinates
mousePositionMode:bind({}, "p", moveMouseToCoordinates)

-- When entering mouse position mode, show a help message
function mousePositionMode:entered()
	hs.alert.show("Mouse Position Mode\nPress 'p' to specify coordinates\nPress ESC to cancel")
end

-- UTILITY FUNCTIONS

-- Get current mouse position (for logging/debugging)
function getCurrentMousePosition()
	local pos = hs.mouse.absolutePosition()
	print("Current mouse position: x=" .. pos.x .. ", y=" .. pos.y)
	return pos
end

-- Bind a key to show current mouse position
hs.hotkey.bind({ "cmd", "shift" }, "P", function()
	local pos = getCurrentMousePosition()
	hs.alert.show("Mouse at: " .. math.floor(pos.x) .. "," .. math.floor(pos.y))
end)

-- Alert to show Hammerspoon is loaded successfully
hs.alert.show("Hammerspoon config loaded")
