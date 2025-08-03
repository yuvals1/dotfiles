local get_selected_or_hovered = ya.sync(function()
	local urls = {}
	
	-- Get selected files
	for _, u in pairs(cx.active.selected) do
		table.insert(urls, u)
	end
	
	-- If no selection, get hovered file
	if #urls == 0 then
		local h = cx.active.current.hovered
		if h then
			table.insert(urls, h.url)
		end
	end
	
	return urls
end)

return {
	entry = function(self, job)
		-- Define emoji rotation order
		local emoji_list = {
			{ emoji = "✅", name = "done" },
			{ emoji = "❗", name = "important" },
			{ emoji = "💤", name = "not important" },
			{ emoji = nil, name = "none" }  -- No emoji state
		}

		-- Get files to process
		local urls = get_selected_or_hovered()
		if #urls == 0 then return end
		
		local renamed_count = 0
		local failed_count = 0
		local last_state = nil
		
		-- Process each file
		for _, url in ipairs(urls) do
			local path = tostring(url)
			local old_name = path:match("([^/]+)$")
			local dir = path:match("(.*/)")
			
			if old_name and dir then
				-- Determine current state by checking which emoji prefix exists
				local current_index = #emoji_list  -- Default to "none" state
				for i, state in ipairs(emoji_list) do
					if state.emoji and old_name:match("^" .. state.emoji .. " ") then
						current_index = i
						break
					end
				end
				
				-- Calculate next state (rotate to next)
				local next_index = (current_index % #emoji_list) + 1
				local next_state = emoji_list[next_index]
				last_state = next_state
				
				-- Build new name
				local new_name = old_name
				
				-- First, remove any existing emoji prefix
				for _, state in ipairs(emoji_list) do
					if state.emoji then
						new_name = new_name:gsub("^" .. state.emoji .. " ", "")
					end
				end
				
				-- Add new emoji prefix if not in "none" state
				if next_state.emoji then
					new_name = next_state.emoji .. " " .. new_name
				end
				
				-- Build new path
				local new_path = dir .. new_name
				
				-- Only rename if name will change
				if old_name ~= new_name then
					local ok = os.rename(path, new_path)
					if ok then
						renamed_count = renamed_count + 1
						-- For single file, maintain focus
						if #urls == 1 then
							ya.manager_emit("reveal", { new_path })
						end
					else
						failed_count = failed_count + 1
					end
				end
			end
		end
		
		-- Show notification with results
		if renamed_count > 0 then
			local content
			if renamed_count == 1 then
				content = "Changed to: " .. (last_state and last_state.name or "unknown")
			else
				content = string.format("%d file(s) changed to: %s", renamed_count, last_state and last_state.name or "unknown")
			end
			
			ya.notify({
				title = "Mark Label",
				content = content,
				timeout = 2,
			})
		elseif failed_count > 0 then
			ya.notify({
				title = "Mark Label",
				content = string.format("%d file(s) failed", failed_count),
				timeout = 2,
			})
		end
	end,
}