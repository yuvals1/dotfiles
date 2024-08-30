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

		local content = ""
		for file in output.stdout:gmatch("[^\r\n]+") do
			local file_content, file_err = Command("cat"):arg(file):output()
			if file_content then
				local relative_path = file:sub(#tostring(dir_url) + 2)
				local language = get_language(file)
				content = content .. "# " .. relative_path .. "\n"
				content = content .. "````" .. language .. "\n"
				content = content .. file_content.stdout
				content = content .. "````\n\n"
			else
				content = content .. "# " .. file .. " (Error reading file: " .. file_err .. ")\n\n"
			end
		end

		ya.clipboard(content)
		info("Directory content copied to clipboard")
	end,
}
