local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if h then
		return h.url, h.name
	end
	return nil, nil
end)

return {
	entry = function(self, job)
		local action = job.args[1]
		
		-- Map actions to emoji
		local emoji_map = {
			important = { emoji = "❗" },
		}

		local config = emoji_map[action]
		if not config then
			return
		end

		-- Get current file
		local url, old_name = get_hovered()
		if not url then return end
		
		-- Check if file already has the emoji prefix
		local has_prefix = old_name:match("^❗ ") ~= nil
		
		local new_name
		if has_prefix then
			-- Remove the emoji prefix (toggle off)
			new_name = old_name:gsub("^❗ ", "")
		else
			-- Add the emoji prefix (toggle on)
			new_name = config.emoji .. " " .. old_name
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
			os.rename(old_path, new_path)
			-- Skip reveal to see if it reduces the glitch
		end
	end,
}
