local function get_log_file_path()
	local home = os.getenv("HOME")
	return home .. "/.config/yazi/yank-selected-content.log"
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
	log_to_file(content)
	return ya.notify({
		title = "Yank Selected Content",
		content = content,
		timeout = 10,
	})
end

local function get_file_content(file_path)
	local output, err = Command("cat"):arg(file_path):output()
	if not output then
		return nil, "Failed to read file: " .. file_path .. ", error: " .. err
	end
	return output.stdout, nil
end

return {
	entry = function()
		local selected_files = safe_access(get_selected_files, {})

		if #selected_files == 0 then
			return info("No files selected")
		end

		local content = ""
		local error_messages = {}
		local file_count = 0
		local total_lines = 0

		for _, file_path in ipairs(selected_files) do
			local file_content, err = get_file_content(file_path)
			if file_content then
				content = content .. "# " .. file_path .. "\n\n"
				content = content .. file_content .. "\n\n"
				file_count = file_count + 1
				total_lines = total_lines + select(2, file_content:gsub("\n", "\n"))
			else
				table.insert(error_messages, err)
			end
		end

		if content ~= "" then
			ya.clipboard(content)
			local success_message =
				string.format("Copied content of %d files (%d lines) to clipboard", file_count, total_lines)
			info(success_message)
		end

		if #error_messages > 0 then
			local error_content = "Errors:\n" .. table.concat(error_messages, "\n")
			info(error_content)
		end
	end,
}
