-- Configuration
local CONFIG = {
	log_to_file = true, -- Set this to false to disable logging to file
}

local function get_log_file_path()
	local home = os.getenv("HOME")
	return home .. "/.config/yazi/yank-selected-content.log"
end

local function log_to_file(message)
	if not CONFIG.log_to_file then
		return
	end
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

-- New functions for directory handling (from yank-dir-content)
local function split_path(path)
	local parts = {}
	for part in path:gmatch("[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

local function compare_paths(a, b)
	local a_parts = split_path(a)
	local b_parts = split_path(b)
	for i = 1, math.min(#a_parts, #b_parts) do
		if a_parts[i] ~= b_parts[i] then
			if a_parts[i]:match("%.yazi$") and not b_parts[i]:match("%.yazi$") then
				return false
			elseif b_parts[i]:match("%.yazi$") and not a_parts[i]:match("%.yazi$") then
				return true
			else
				return a_parts[i] < b_parts[i]
			end
		end
	end
	return #a_parts < #b_parts
end

local function generate_tree(dir_url)
	local output, err = Command("tree"):arg("-L"):arg("3"):arg("--charset=ascii"):arg(tostring(dir_url)):output()

	if not output then
		return "Failed to generate tree, error: " .. err
	end

	return output.stdout
end

local function process_directory(dir_url, base_level)
	base_level = base_level or 1
	local tree_content = generate_tree(dir_url)

	local output, err = Command("find"):arg(tostring(dir_url)):output()
	if not output then
		return nil, "Failed to list directory contents, error: " .. err
	end

	local paths = {}
	for path in output.stdout:gmatch("[^\r\n]+") do
		table.insert(paths, path)
	end
	table.sort(paths, compare_paths)

	local content = tree_content .. "\n\n"
	local prev_parts = {}
	local total_lines = 0
	local file_count = 0
	local skipped_count = 0

	for _, path in ipairs(paths) do
		local formatted_path = get_relative_path(path, tostring(dir_url))
		local parts = split_path(formatted_path)
		local is_file = safe_access(function()
			return not fs.stat(path).is_dir
		end, false)

		for i = 1, #parts do
			if i > #prev_parts or parts[i] ~= prev_parts[i] then
				content = content
					.. string.rep("#", base_level + i - 1)
					.. " "
					.. table.concat(parts, "/", 1, i)
					.. "\n"
			end
		end

		if is_file then
			local language = get_language(path)
			if language then
				local file_content, file_err = get_file_content(path)
				if file_content then
					content = content .. "````" .. language .. "\n"
					content = content .. file_content
					content = content .. "````\n\n"

					local file_lines = select(2, file_content:gsub("\n", "\n"))
					total_lines = total_lines + file_lines
					file_count = file_count + 1
				else
					content = content .. "Error reading file: " .. file_err .. "\n\n"
				end
			else
				skipped_count = skipped_count + 1
			end
		end

		prev_parts = parts
	end

	return content, file_count, total_lines, skipped_count
end

return {
	entry = function()
		local selected_files = safe_access(get_selected_files, {})

		if #selected_files == 0 then
			return info("No files selected")
		end

		local content = ""
		local error_messages = {}
		local total_file_count = 0
		local total_lines = 0
		local total_skipped = 0

		for _, file_path in ipairs(selected_files) do
			local is_dir = safe_access(function()
				return fs.stat(file_path).is_dir
			end, false)

			if is_dir then
				local dir_content, file_count, lines_count, skipped_count = process_directory(file_path, 1)
				if dir_content then
					content = content .. "# Directory: " .. ya.basename(file_path) .. "\n\n"
					content = content .. dir_content
					total_file_count = total_file_count + file_count
					total_lines = total_lines + lines_count
					total_skipped = total_skipped + skipped_count
				else
					table.insert(error_messages, "Failed to process directory: " .. file_path)
				end
			else
				local file_content, err = get_file_content(file_path)
				if file_content then
					local language = get_language(file_path)
					content = content .. "# File: " .. ya.basename(file_path) .. "\n"
					content = content .. "````" .. language .. "\n"
					content = content .. file_content
					content = content .. "````\n\n"
					total_file_count = total_file_count + 1
					total_lines = total_lines + select(2, file_content:gsub("\n", "\n"))
				else
					table.insert(error_messages, err)
				end
			end
		end

		if content ~= "" then
			ya.clipboard(content)
			local success_message = string.format(
				"Copied content of %d files (%d lines) to clipboard. Skipped %d unsupported files.",
				total_file_count,
				total_lines,
				total_skipped
			)
			info(success_message)
		end

		if #error_messages > 0 then
			local error_content = "Errors:\n" .. table.concat(error_messages, "\n")
			info(error_content)
		end
	end,
}
