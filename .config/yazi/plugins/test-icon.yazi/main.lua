-- Test plugin to add a red dot before file icons for tagged files

local get_mactag_state = ya.sync(function()
	-- Try to get the mactag-red plugin's state
	local status, mactag = pcall(function()
		return package.loaded["mactag-red"]
	end)
	
	if status and mactag then
		-- Return the tags table from mactag-red's state
		return mactag.tags or {}
	end
	
	return {}
end)

local function setup(state)
	-- Save the original icon function
	state.original_icon = Entity.icon
	
	-- Override the icon function
	Entity.icon = function(self)
		-- Get the original icon
		local original = state.original_icon(self)
		
		-- Get the file URL
		local url = tostring(self._file.url)
		
		-- Get tags from mactag-red plugin
		local tags = get_mactag_state()
		
		-- Check if this file has any tags
		local file_tags = tags[url]
		
		-- Only add red dot if file is tagged
		if file_tags and #file_tags > 0 then
			-- File is tagged - add red dot before icon
			local red_dot = ui.Span("● "):fg("#ee7b70")
			return ui.Line { red_dot, original }
		else
			-- File is not tagged - show original icon only
			return original
		end
	end
end

return { setup = setup }