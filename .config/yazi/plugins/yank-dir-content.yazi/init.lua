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
			sh = "bash",
			yaml = "yaml",
			-- Add more as needed
		}
		return extensions[ext] or ""
	end
	return ""
end

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

		local output, err = Command("find"):arg(tostring(dir_url)):arg("-type"):arg("f"):output()
		if not output then
			return info("Failed to list directory contents, error: " .. err)
		end

		local files = {}
		for file in output.stdout:gmatch("[^\r\n]+") do
			table.insert(files, file)
		end

		local content = ""
		for _, file in ipairs(files) do
			local file_content, file_err = Command("cat"):arg(file):output()
			if file_content then
				local file_name = file:match("([^/]+)$")
				local language = get_language(file_name)
				content = content .. "# " .. file_name .. "\n"
				content = content .. "```" .. language .. "\n"
				content = content .. file_content.stdout
				content = content .. "```\n\n"
			else
				content = content .. "# " .. file .. " (Error reading file: " .. file_err .. ")\n\n"
			end
		end

		ya.clipboard(content)
		info("Directory content copied to clipboard")
	end,
}
