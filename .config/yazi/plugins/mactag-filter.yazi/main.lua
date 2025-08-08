--- Filter to show only files tagged with macOS Red tag
--- Depends on mactag-unified plugin for tag state

-- Store filter state in plugin state
local get_filter_state = ya.sync(function(st)
	return st.filter_active or false
end)

local set_filter_state = ya.sync(function(st, active)
	st.filter_active = active
end)

-- Get tagged files from unified plugin's state
local get_tagged_files = ya.sync(function()
    -- Access unified state
    local toggle_state = package.loaded["mactag-unified"]
	if not toggle_state or not toggle_state.tags then
		return {}
	end
	
	local folder = cx.active.current
	local tagged_names = {}
	
	-- Check each file in the current directory
	for _, file in ipairs(folder.window) do
		local url = tostring(file.url)
        -- Check if this file has the Red tag
        if toggle_state.tags[url] then
            for _, tag in ipairs(toggle_state.tags[url]) do
				if tag == "Red" then
					-- Store just the filename
					table.insert(tagged_names, file.name)
					break
				end
			end
		end
	end
	
	return tagged_names
end)

-- Escape special regex characters in filename
local function escape_pattern(str)
	-- Escape special regex characters
	local special_chars = "^$()%.[]*+-?{}"
	local escaped = str:gsub("([%" .. special_chars .. "])", "\\%1")
	return escaped
end

return {
	setup = function(st)
		-- Initialize state
		st.filter_active = false
	end,
	
	entry = function(self, job)
		-- Toggle filter on/off
		local is_active = get_filter_state()
		
		if is_active then
			-- Clear the filter
			ya.manager_emit("filter_do", { "" })
			set_filter_state(false)
			
			ya.notify {
				title = "Tag Filter",
				content = "Filter cleared",
				timeout = 2,
			}
			return
		end
		
		-- Get list of tagged filenames
		local tagged = get_tagged_files()
		
		if #tagged == 0 then
			ya.notify {
				title = "Tag Filter",
				content = "No tagged files to filter",
				timeout = 2,
			}
			return
		end
		
		-- Build regex pattern: (file1|file2|file3)
		local patterns = {}
		for _, name in ipairs(tagged) do
			table.insert(patterns, escape_pattern(name))
		end
		
		-- Create OR pattern for all tagged files
		local filter_pattern = "^(" .. table.concat(patterns, "|") .. ")$"
		
		-- Apply the filter
		ya.manager_emit("filter_do", { filter_pattern })
		set_filter_state(true)
		
		ya.notify {
			title = "Tag Filter",
			content = string.format("Filtering %d tagged files", #tagged),
			timeout = 2,
		}
	end,
}