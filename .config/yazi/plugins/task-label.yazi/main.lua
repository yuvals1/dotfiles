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
		
		-- Calculate new name first
		-- Remove any existing emoji prefix (including the space)
		local new_name = old_name
		-- Try each emoji separately since Lua patterns might not handle Unicode character classes well
		new_name = new_name:gsub("^❗ ", "")
		-- Add the new emoji prefix
		new_name = config.emoji .. " " .. new_name
		
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
			end
		end
	end,
}
