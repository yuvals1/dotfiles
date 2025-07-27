return {
	entry = function()
		local value, event = ya.input({
			title = "Create file:",
			position = { "top-center", y = 2, w = 40 },
		})
		if event == 1 and value ~= "" then
			local path = value
			local name = value:match("([^/]+)$") or value
			
			-- Create the file with template content
			local content = string.format([[Label:
Due:
]], name)
			
			local file = io.open(path, "w")
			if file then
				file:write(content)
				file:close()
				ya.manager_emit("refresh", {})
			else
				ya.notify({
					title = "Failed to create file",
					content = "Could not create " .. path,
					timeout = 3,
					level = "error",
				})
			end
		end
	end,
}
