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

-- Function to apply tag changes
local function apply_tag_change(urls, current_state, next_state)
	local files = {}
	for _, url in ipairs(urls) do
		files[#files + 1] = tostring(url)
	end
	
	-- First, remove old tags if needed
	if STATES[current_state].tag then
		-- Remove the current tag
		local remove_cmd = Command("tag"):arg("-r"):arg(STATES[current_state].tag)
		for _, file in ipairs(files) do
			remove_cmd = remove_cmd:arg(file)
		end
		remove_cmd:status()
	end
	
	-- Then add new tag if needed
	if STATES[next_state].tag then
		-- Add the new tag
		local add_cmd = Command("tag"):arg("-a"):arg(STATES[next_state].tag)
		for _, file in ipairs(files) do
			add_cmd = add_cmd:arg(file)
		end
		add_cmd:status()
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
	
	-- Apply the tag change
	apply_tag_change(urls, current_state, next_state)
	
	-- Show notification
	ya.notify {
		title = "Tag Rotate",
		content = string.format(
			"Rotated %d file(s): %s → %s",
			#urls,
			STATES[current_state].display,
			STATES[next_state].display
		),
		timeout = 2,
	}
	
	-- Trigger mactag-toggle's fetch to update the visual state
	-- We need to create file objects for the fetch
	local files = {}
	for _, url in ipairs(urls) do
		files[#files + 1] = { url = url }
	end
	
	-- Try to call mactag-toggle's fetch if it exists
	local toggle_module = package.loaded["mactag-toggle"]
	if toggle_module and toggle_module.fetch then
		toggle_module.fetch(nil, { files = files })
	end
end

return { entry = entry }