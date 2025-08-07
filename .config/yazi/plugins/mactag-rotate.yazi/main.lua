--- Rotate between different macOS tag states
--- Step 3: Read current tag state from files

-- Define the rotation states
local STATES = {
	{ tag = nil,    display = "None" },      -- No tag
	{ tag = "Red",  display = "Red (●)" },   -- Red dot
	{ tag = "Done", display = "Done (✅)" }, -- Done emoji
}

-- Helper to get selected or hovered files (same as mactag-toggle)
local selected_or_hovered = ya.sync(function()
	local tab, urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		urls[#urls + 1] = u
	end
	if #urls == 0 and tab.current.hovered then
		urls[1] = tab.current.hovered.url
	end
	return urls
end)

-- Function to get current tag state of a file
local function get_current_state(file_path)
	-- Run the tag command to get current tags
	local output = Command("tag"):arg("-l"):arg(file_path):output()
	
	if not output or not output.stdout then
		return 1  -- No tags = state 1 (None)
	end
	
	-- Check what tags the file has
	local tags_str = output.stdout
	
	-- Check for our specific tags
	if string.find(tags_str, "Done") then
		return 3  -- State 3 = Done
	elseif string.find(tags_str, "Red") then
		return 2  -- State 2 = Red
	else
		return 1  -- State 1 = None
	end
end

local function entry(_, job)
	-- Get selected files
	local urls = selected_or_hovered()
	if #urls == 0 then
		ya.notify {
			title = "Tag Rotate",
			content = "No files selected",
			timeout = 1,
		}
		return
	end
	
	-- Get the current state of the first file
	local first_file = tostring(urls[1])
	local current_state = get_current_state(first_file)
	local next_state = (current_state % #STATES) + 1
	
	ya.notify {
		title = "Tag Rotate",
		content = string.format(
			"Current: %s → Next: %s (%d file(s))",
			STATES[current_state].display,
			STATES[next_state].display,
			#urls
		),
		timeout = 2,
	}
	
	-- Debug: also show raw tag output for the first file
	local debug_output = Command("tag"):arg("-l"):arg(first_file):output()
	if debug_output and debug_output.stdout then
		ya.notify {
			title = "Debug: Current tags",
			content = debug_output.stdout == "" and "(no tags)" or debug_output.stdout,
			timeout = 3,
		}
	end
end

return { entry = entry }