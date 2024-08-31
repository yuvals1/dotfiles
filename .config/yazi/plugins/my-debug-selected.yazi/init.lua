local function get_log_file_path()
	local home = os.getenv("HOME")
	return home .. "/.config/yazi/my-debug-selected.log"
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

local get_selected_files = ya.sync(function()
	local selected = {}
	for _, u in pairs(cx.active.selected) do
		table.insert(selected, tostring(u))
	end
	return selected
end)

local function info(content)
	log_to_file(content) -- Log to file
	return ya.notify({
		title = "Selected Files",
		content = content,
		timeout = 10,
	})
end

return {
	entry = function()
		local selected_files = safe_access(get_selected_files, {})

		if #selected_files == 0 then
			return info("No files selected")
		end

		local content = "Selected files:\n"
		for i, file in ipairs(selected_files) do
			content = content .. i .. ". " .. file .. "\n"
		end

		info(content)
	end,
}
