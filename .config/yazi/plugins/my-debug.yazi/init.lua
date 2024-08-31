-- plugins/show-yazi-state.yazi/init.lua

local get_state = ya.sync(function()
	local tab = cx.active
	local current = tab.current
	local hovered = current.hovered

	local last_modified = "N/A"
	if hovered and hovered.cha and hovered.cha.modified then
		last_modified = tostring(hovered.cha.modified)
	end

	return {
		cwd = tostring(current.cwd),
		hovered = hovered and hovered.name or "None",
		hovered_modified = last_modified,
		selected_count = #tab.selected,
		total_files = #current.files,
		sorted_by = tab.conf.sort_by,
		show_hidden = tab.conf.show_hidden,
		current_mode = tostring(tab.mode),
		yanked_count = #cx.yanked,
	}
end)

local function format_time(time_str)
	local seconds, fractional = time_str:match("(%d+)%.(%d+)")
	if seconds and fractional then
		local time = tonumber(seconds)
		if time then
			return os.date("%Y-%m-%d %H:%M:%S", time) .. "." .. fractional
		end
	end
	return time_str -- Return as is if parsing fails
end

local function info(content)
	return ya.notify({
		title = "Yazi State",
		content = content,
		timeout = 10, -- Increased timeout for more reading time
	})
end

return {
	entry = function()
		local state = get_state()
		if not state then
			return info("Unable to get Yazi state")
		end

		local content = string.format(
			"CWD: %s\n"
				.. "Hovered: %s\n"
				.. "Hovered Last Modified: %s\n"
				.. "Selected: %d of %d files\n"
				.. "Sorted by: %s\n"
				.. "Show hidden: %s\n"
				.. "Current mode: %s\n"
				.. "Yanked files: %d",
			state.cwd,
			state.hovered,
			format_time(state.hovered_modified),
			state.selected_count,
			state.total_files,
			state.sorted_by,
			state.show_hidden and "Yes" or "No",
			state.current_mode,
			state.yanked_count
		)

		info(content)
	end,
}
