-- Helper to get hovered file
local get_hovered = ya.sync(function()
	local tab = cx.active
	if tab.current.hovered then
		return tab.current.hovered.url
	end
	return nil
end)

-- Update visual state (similar to mactag-toggle's update function)
local update_visual = ya.sync(function(st, tags)
	-- Access mactag-toggle's state to update visual
	local toggle_module = package.loaded["mactag-toggle"]
	if toggle_module then
		for path, tag in pairs(tags) do
			toggle_module.tags[path] = #tag > 0 and tag or nil
		end
	end
	-- Trigger render
	if ui.render then
		ui.render()
	else
		ya.render()
	end
end)

-- Function to check if file has Done tag
local function has_done_tag(file_path)
	local output = Command("tag"):arg("-l"):arg(file_path):output()
	
	if not output or not output.stdout then
		return false
	end
	
	local tags_str = output.stdout
	return string.find(tags_str, "Done") ~= nil
end

-- Function to add Done tag to a file
local function add_done_tag(file_path)
	local cmd = Command("tag"):arg("-a"):arg("Done"):arg(file_path)
	local result = cmd:status()
	return result and result.success
end

return {
	entry = function()
		-- Get the hovered file
		local hovered_url = get_hovered()
		
		if not hovered_url then
			ya.notify({
				title = "Done and Next",
				content = "No file hovered",
				timeout = 1,
			})
			return
		end
		
		local file_path = tostring(hovered_url)
		local already_done = has_done_tag(file_path)
		
		if already_done then
			ya.notify({
				title = "Done and Next",
				content = "Already marked as Done ✅",
				timeout = 1,
			})
		else
			-- Add the Done tag
			local success = add_done_tag(file_path)
			if success then
				ya.notify({
					title = "Done and Next",
					content = "Marked as Done ✅",
					timeout = 1,
				})
				-- Update visual state immediately
				update_visual({ [file_path] = { "Done" } })
			else
				ya.notify({
					title = "Done and Next",
					content = "Failed to add Done tag",
					timeout = 2,
					level = "error",
				})
			end
		end
		
		-- Move cursor down by one position
		ya.manager_emit("arrow", { 1 })
	end,
}