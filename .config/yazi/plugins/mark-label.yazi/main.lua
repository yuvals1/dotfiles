local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if h then
		return h.url, h.name
	end
	return nil, nil
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

		-- Get current file
		local url, old_name = get_hovered()
		if not url then return end
		
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
		
		-- Build paths
		local old_path = tostring(url)
		local dir = old_path:match("(.*/)")
		if not dir then
			ya.notify({
				title = "Error",
				content = "Could not extract directory",
				timeout = 2,
			})
			return
		end
		local new_path = dir .. new_name
		
		-- Only rename if name will change
		if old_name ~= new_name then
			local ok = os.rename(old_path, new_path)
			if ok then
				-- Tell yazi to reveal the new file to maintain focus
				ya.manager_emit("reveal", { new_path })
				
				-- Show notification of current state
				ya.notify({
					title = "Mark Label",
					content = "Changed to: " .. next_state.name,
					timeout = 1,
				})
			else
				ya.notify({
					title = "Error",
					content = "Failed to rename file",
					timeout = 2,
				})
			end
		end
	end,
}