local function get_log_file_path()
	local home = os.getenv("HOME")
	return home .. "/.config/yazi/my-debug.log"
end

local function log_to_file(message)
	local log_file = io.open(get_log_file_path(), "a")
	if log_file then
		local timestamp = os.date("%Y-%m-%d %H:%M:%S")
		log_file:write(string.format("[%s] %s\n", timestamp, message))
		log_file:close()
	end
end

local function safe_access(func, default)
	local success, result = pcall(func)
	if success then
		return result
	else
		return "Error: " .. tostring(result)
	end
end

local get_state = ya.sync(function()
	local tab = cx.active
	local current = tab.current
	local hovered = current.hovered

	local function get_last_modified()
		if hovered and hovered.cha.modified then
			return safe_access(function()
				return os.date("%Y-%m-%d %H:%M:%S", hovered.cha.modified)
			end, "N/A")
		end
		return "N/A"
	end

	return {
		cwd = safe_access(function()
			return tostring(current.cwd)
		end, "Unknown"),
		hovered = safe_access(function()
			return hovered and hovered.name or "None"
		end, "Error"),
		hovered_modified = get_last_modified(),
		selected_count = safe_access(function()
			return #tab.selected
		end, 0),
		total_files = safe_access(function()
			return #current.files
		end, 0),
		sorted_by = safe_access(function()
			return tab.conf.sort_by
		end, "Unknown"),
		show_hidden = safe_access(function()
			return tab.conf.show_hidden
		end, false),
		current_mode = safe_access(function()
			return tostring(tab.mode)
		end, "Unknown"),
		yanked_count = safe_access(function()
			return #cx.yanked
		end, 0),
		current_index = safe_access(function()
			return current.index
		end, 0),
		preview_enabled = safe_access(function()
			return tab.preview.enabled
		end, false),
		filetype = safe_access(function()
			return hovered and hovered.ftype or "Unknown"
		end, "Error"),
		file_size = safe_access(function()
			return hovered and hovered.size and tostring(hovered.size) or "Unknown"
		end, "Error"),
	}
end)

local function info(content)
	log_to_file(content) -- Log to file
	return ya.notify({
		title = "Yazi State",
		content = content,
		timeout = 15,
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
				.. "Yanked files: %d\n"
				.. "Current index: %s\n"
				.. "Preview enabled: %s\n"
				.. "Filetype: %s\n"
				.. "File size: %s",
			state.cwd,
			state.hovered,
			state.hovered_modified,
			state.selected_count,
			state.total_files,
			state.sorted_by,
			state.show_hidden and "Yes" or "No",
			state.current_mode,
			state.yanked_count,
			state.current_index,
			state.preview_enabled and "Yes" or "No",
			state.filetype,
			state.file_size
		)
		info(content)
	end,
}
