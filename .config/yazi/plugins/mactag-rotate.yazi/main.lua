--- Rotate between different macOS tag states

-- Define the rotation states
local STATES = {
	{ tag = nil,     display = "None" },       -- No tag
	{ tag = "Done",  display = "Done (✅)" },  -- Done emoji
	{ tag = "Red",   display = "Red (●)" },    -- Red dot
	{ tag = "X",     display = "X (❌)" },     -- X emoji
	{ tag = "Sleep", display = "Sleep (💤)" }, -- Sleep emoji
}

-- Update mactag-toggle's state and trigger render (similar to mactag-toggle's update function)
local update_toggle_state = ya.sync(function(st, tags)
	-- Access mactag-toggle's state
	local toggle_module = package.loaded["mactag-toggle"]
	if toggle_module then
		for path, tag in pairs(tags) do
			toggle_module.tags[path] = #tag > 0 and tag or nil
		end
	end
	-- Trigger render
	if ui.render then
		ui.render()
	else
		ya.render()
	end
end)

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
	if string.find(tags_str, "Sleep") then
		return 5  -- State 5 = Sleep
	elseif string.find(tags_str, "X") then
		return 4  -- State 4 = X
	elseif string.find(tags_str, "Red") then
		return 3  -- State 3 = Red
	elseif string.find(tags_str, "Done") then
		return 2  -- State 2 = Done
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
	
	-- Update mactag-toggle's state for immediate visual update
	local tags_update = {}
	for _, url in ipairs(urls) do
		local path = tostring(url)
		if STATES[next_state].tag then
			tags_update[path] = { STATES[next_state].tag }
		else
			tags_update[path] = {}
		end
	end
	update_toggle_state(tags_update)
end

return { entry = entry }