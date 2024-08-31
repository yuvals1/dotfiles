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

local function get_language(file)
	local ext = file:match("%.([^%.]+)$")
	if ext then
		ext = ext:lower()
		local extensions = {
			py = "python",
			js = "javascript",
			html = "html",
			css = "css",
			lua = "lua",
			md = "markdown",
			txt = "text",
			-- Add more as needed
		}
		return extensions[ext] or "text"
	end
	return "text"
end

local function find_common_ancestor(paths)
	if #paths == 0 then
		return ""
	end
	if #paths == 1 then
		return ya.parent_path(paths[1])
	end

	local parts = {}
	for _, path in ipairs(paths) do
		local path_parts = {}
		for part in path:gmatch("[^/]+") do
			table.insert(path_parts, part)
		end
		table.insert(parts, path_parts)
	end

	local common = {}
	for i = 1, #parts[1] do
		local part = parts[1][i]
		local is_common = true
		for j = 2, #parts do
			if parts[j][i] ~= part then
				is_common = false
				break
			end
		end
		if is_common then
			table.insert(common, part)
		else
			break
		end
	end

	return "/" .. table.concat(common, "/")
end

local function get_relative_path(file_path, common_ancestor)
	return file_path:sub(#common_ancestor + 2) -- +2 to remove leading '/'
end

return {
	entry = function()
		local selected_files = safe_access(get_selected_files, {})

		if #selected_files == 0 then
			return info("No files selected")
		end

		local common_ancestor = find_common_ancestor(selected_files)

		local content = "# Common ancestor: " .. common_ancestor .. "\n\n"
		local error_messages = {}
		local file_count = 0
		local total_lines = 0

		for _, file_path in ipairs(selected_files) do
			local file_content, err = get_file_content(file_path)
			if file_content then
				local relative_path = get_relative_path(file_path, common_ancestor)
				local language = get_language(file_path)
				content = content .. "## " .. relative_path .. "\n"
				content = content .. "````" .. language .. "\n"
				content = content .. file_content
				content = content .. "````\n\n"
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
