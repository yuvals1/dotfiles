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

		local output, err = Command("find")
			:arg(tostring(dir_url))
			:arg("-type")
			:arg("f")
			:arg("-exec")
			:arg("cat")
			:arg("{}")
			:arg("+")
			:output()
		if not output then
			return info("Failed to read directory contents, error: " .. err)
		end

		ya.clipboard(output.stdout)
		info("Directory content copied to clipboard")
	end,
}
