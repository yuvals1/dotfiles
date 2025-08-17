--- Jump between files tagged with any macOS tag
--- Depends on mactag-unified plugin for tag state

-- Get info about current folder and tagged files from unified state
local get_jump_info = ya.sync(function()
    -- Access unified tag state
    local toggle_state = package.loaded["mactag-unified"]
	if not toggle_state or not toggle_state.tags then
		return { positions = {}, cursor = 0, offset = 0 }
	end
	
	local folder = cx.active.current
	local tagged_positions = {}
	
	-- Check each file in the visible window
	for i, file in ipairs(folder.window) do
		local url = tostring(file.url)
        -- Check against unified stored tags
		if toggle_state.tags[url] and #toggle_state.tags[url] > 0 then
			-- File has at least one tag
			table.insert(tagged_positions, i)
		end
	end
	
	return {
		positions = tagged_positions,
		cursor = folder.cursor,
		offset = folder.offset,
		window_size = #folder.window
	}
end)

local function entry(_, job)
	assert(job.args[1] == "next" or job.args[1] == "prev", "Invalid action: use 'next' or 'prev'")
	
	-- Get folder info and tagged positions
	local info = get_jump_info()
	
	if #info.positions == 0 then
		ya.notify {
			title = "Tag Jump",
			content = "No tagged files found",
			timeout = 1,
		}
		return
	end
	
	-- Calculate current position in window
	local current_window_pos = info.cursor - info.offset + 1
	local target_pos = nil
	
	if job.args[1] == "next" then
		-- Find next tagged position after current
		for _, pos in ipairs(info.positions) do
			if pos > current_window_pos then
				target_pos = pos
				break
			end
		end
		-- Wrap to first if none found
		target_pos = target_pos or info.positions[1]
	else
		-- Find previous tagged position before current
		for i = #info.positions, 1, -1 do
			if info.positions[i] < current_window_pos then
				target_pos = info.positions[i]
				break
			end
		end
		-- Wrap to last if none found
		target_pos = target_pos or info.positions[#info.positions]
	end
	
	-- Calculate jump distance using keyjump's formula
	-- target_pos is 1-based position in window
	-- Formula: (target_pos - 1) + offset - cursor
	local jump_distance = (target_pos - 1) + info.offset - info.cursor
	
	ya.manager_emit("arrow", { jump_distance })
end

return { entry = entry }