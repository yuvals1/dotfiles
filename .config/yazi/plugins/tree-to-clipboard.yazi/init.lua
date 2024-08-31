local function info(content)
	return ya.notify({
		title = "ASCII Tree",
		content = content,
		timeout = 5,
	})
end

local current_dir = ya.sync(function()
	return cx.active.current.cwd
end)

return {
	entry = function()
		local dir = current_dir()
		if not dir then
			return info("Failed to get current directory")
		end

		local output, err = Command("tree")
			:arg("-L")
			:arg("3") -- Limit depth to 3 levels, adjust as needed
			:arg("--charset=ascii") -- Use ASCII characters for compatibility
			:arg(tostring(dir))
			:output()

		if not output then
			return info("Failed to generate tree, error: " .. err)
		end

		local tree = output.stdout
		local line_count = select(2, tree:gsub("\n", "\n"))

		ya.clipboard(tree)
		info(string.format("Copied ASCII tree with %d lines to clipboard", line_count))
	end,
}
