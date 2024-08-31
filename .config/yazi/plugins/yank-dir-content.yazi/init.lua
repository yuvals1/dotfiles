local function info(content)
	return ya.notify({
		title = "Yank Directory Content",
		content = content,
		timeout = 5,
	})
end

local hovered_url = ya.sync(function()
	local h = cx.active.current.hovered
	return h and h.url
end)

-- Function to get the file extension
local function get_file_extension(filename)
	return filename:match("%.([^%.]+)$") or ""
end

-- Function to get the language based on file extension
local function get_language(filename)
	local ext = get_file_extension(filename):lower()
	local extensions = {
		py = "python",
		js = "javascript",
		html = "html",
		css = "css",
		lua = "lua",
		-- Add more mappings as needed
	}
	return extensions[ext] or ""
end

return {
	entry = function()
		local dir_url = hovered_url()
		if not dir_url then
			return info("No directory hovered")
		end

		local is_dir = ya.sync(function()
			return cx.active.current.hovered.cha.is_dir
		end)
		if not is_dir then
			return info("Hovered item is not a directory")
		end

		-- List all files in the directory
		local output, err = Command("find"):arg(tostring(dir_url)):arg("-type"):arg("f"):output()
		if not output then
			return info("Failed to list directory contents, error: " .. tostring(err))
		end

		local files = {}
		for file in output.stdout:gmatch("[^\r\n]+") do
			table.insert(files, file)
		end

		local content = ""
		for _, file in ipairs(files) do
			-- Read file content
			local file_content, file_err = Command("cat"):arg(file):output()
			local file_name = file:match("([^/]+)$") or "Unknown"
			local language = get_language(file_name)

			content = content .. "# " .. file_name .. "\n"
			if file_content then
				content = content .. "```" .. language .. "\n" .. file_content.stdout .. "```\n\n"
			else
				content = content .. "Error reading file: " .. tostring(file_err) .. "\n\n"
			end
		end

		if content == "" then
			return info("No file content to copy")
		end

		local ok, clip_err = ya.clipboard(content)
		if ok then
			info("Directory content copied to clipboard")
		else
			info("Failed to copy to clipboard: " .. tostring(clip_err))
		end
	end,
}
