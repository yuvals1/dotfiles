-- Helper to get hovered file
local get_hovered = ya.sync(function()
	local tab = cx.active
	if tab.current.hovered then
		return tab.current.hovered.url
	end
	return nil
end)

-- Helper to get all currently selected files (as string paths)
local get_selected_paths = ya.sync(function()
    local tab = cx.active
    local selected_paths = {}
    for _, url in pairs(tab.selected) do
        selected_paths[#selected_paths + 1] = tostring(url)
    end
    return selected_paths
end)

-- Update visual state (similar to unified update function)
local update_visual = ya.sync(function(st, tags)
	-- Access unified state to update visual
	local unified = package.loaded["mactag-unified"]
	if unified and unified.tags then
		for path, tag in pairs(tags) do
			unified.tags[path] = #tag > 0 and tag or nil
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
-- Function to add Done tag to a file
local function add_done_tag(file_path)
	local cmd = Command("tag"):arg("-a"):arg("Done"):arg(file_path)
	local result = cmd:status()
	return result and result.success
end

return {
	entry = function()
        -- If multiple files are selected, mark all as Done and do not move cursor
        local selected_paths = get_selected_paths()
        if #selected_paths >= 2 then
            local args = { "-a", "Done" }
            for _, path in ipairs(selected_paths) do
                args[#args + 1] = path
            end

            local status = Command("tag"):arg(args):status()
            if status and status.success then
                local tags_update = {}
                for _, path in ipairs(selected_paths) do
                    tags_update[path] = { "Done" }
                end
                -- Update visual state immediately for all selected files
                update_visual(tags_update)
                -- Optional single summary notification (avoid spam)
                ya.notify({
                    title = "Done",
                    content = string.format("Marked %d files as Done", #selected_paths),
                    timeout = 1,
                })
            else
                ya.notify({
                    title = "Done",
                    content = "Failed to add Done tag to selected files",
                    timeout = 2,
                    level = "error",
                })
            end
            return
        end

        -- Fallback to single-file behavior: operate on hovered and move to next
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
        local success = add_done_tag(file_path)
        if success then
            update_visual({ [file_path] = { "Done" } })
        else
            ya.notify({
                title = "Done and Next",
                content = "Failed to add Done tag",
                timeout = 2,
                level = "error",
            })
        end

        ya.manager_emit("arrow", { 1 })
	end,
}