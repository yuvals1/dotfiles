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
		
		-- Map actions to emoji and label
		local emoji_map = {
			important = { emoji = "🧨", label = "🧨" },
			ready = { emoji = "🟢", label = "🟢" },
			waiting = { emoji = "🔴", label = "🔴" },
		}

		local config = emoji_map[action]
		if not config then
			return
		end

		-- Get current file
		local url, old_name = get_hovered()
		if not url then return end
		
		-- Update label in file
		os.execute(string.format("sed -i '' 's/^Label:.*/Label: %s/' '%s'", config.label, tostring(url)))
		
		-- Calculate new name
		local new_name = old_name:gsub("^[🧨🟢🔴] ", "") -- Remove existing emoji
		new_name = config.emoji .. " " .. new_name
		
		-- Only rename if needed
		if old_name ~= new_name then
			-- Build paths using string manipulation
			local old_path = tostring(url)
			-- Extract directory path
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
			
			-- Try the rename
			local ok = os.rename(old_path, new_path)
			if ok then
				-- Tell yazi to reveal the new file to maintain focus
				ya.manager_emit("reveal", { new_path })
			end
		end
	end,
}