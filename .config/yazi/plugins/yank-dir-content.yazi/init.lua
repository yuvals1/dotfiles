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
			-- Add more as needed
		}
		return extensions[ext] or ""
	end
	return ""
end

-- New function to generate tree structure
local function generate_tree(dir_url)
	local output, err = Command("tree")
		:arg("-L")
		:arg("3") -- Limit depth to 3 levels, adjust as needed
		:arg("--charset=ascii") -- Use ASCII characters for compatibility
		:arg(tostring(dir_url))
		:output()

	if not output then
		return "Failed to generate tree, error: " .. err
	end

	return output.stdout
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

		-- Generate tree structure
		local tree_content = generate_tree(dir_url)

		local output, err = Command("find"):arg(tostring(dir_url)):arg("-type"):arg("f"):output()
		if not output then
			return info("Failed to list directory contents, error: " .. err)
		end

		local content = tree_content .. "\n\n" -- Add tree content at the top
		local total_lines = 0
		local file_count = 0

		for file in output.stdout:gmatch("[^\r\n]+") do
			local file_content, file_err = Command("cat"):arg(file):output()
			if file_content then
				local relative_path = file:sub(#tostring(dir_url) + 2)
				local language = get_language(file)
				content = content .. "# " .. relative_path .. "\n"
				content = content .. "````" .. language .. "\n"
				content = content .. file_content.stdout
				content = content .. "````\n\n"

				-- Count lines in this file
				local file_lines = select(2, file_content.stdout:gsub("\n", "\n"))
				total_lines = total_lines + file_lines
				file_count = file_count + 1
			else
				content = content .. "# " .. file .. " (Error reading file: " .. file_err .. ")\n\n"
			end
		end

		ya.clipboard(content)
		info(string.format("Copied tree and content of %d files (%d lines) to clipboard", file_count, total_lines))
	end,
}
