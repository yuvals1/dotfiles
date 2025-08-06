--- @since 25.5.31

local update = ya.sync(function(st, tags)
	for path, tag in pairs(tags) do
		st.tags[path] = #tag > 0 and tag or nil
	end
	-- TODO: remove this
	if ui.render then
		ui.render()
	else
		ya.render()
	end
end)

local selected_or_hovered = ya.sync(function()
	local tab, urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		urls[#urls + 1] = u
	end
	if #urls == 0 and tab.current.hovered then
		urls[1] = tab.current.hovered.url
	end
	return urls
end)

local function setup(st, opts)
	st.tags = {}
	-- Hardcode red color
	st.red_color = opts and opts.color or "#ee7b70"

	-- Save the original icon function
	st.original_icon = Entity.icon
	
	-- Override the icon function to show dots on the left
	Entity.icon = function(self)
		-- Get the original icon
		local original = st.original_icon(self)
		
		-- Get the file URL
		local url = tostring(self._file.url)
		
		-- Check if this file has the Red tag
		local file_tags = st.tags[url]
		
		-- Only add red dot if file is tagged with "Red"
		if file_tags then
			for _, tag in ipairs(file_tags) do
				if tag == "Red" then
					-- File is tagged - add red dot before icon
					local red_dot = ui.Span("● "):fg(st.red_color)
					return ui.Line { red_dot, original }
				end
			end
		end
		
		-- File is not tagged - show original icon only
		return original
	end

end

local function fetch(_, job)
	local paths = {}
	for _, file in ipairs(job.files) do
		paths[#paths + 1] = tostring(file.url)
	end

	local output, err = Command("tag"):arg(paths):stdout(Command.PIPED):output()
	if not output then
		return true, Err("Cannot spawn `tag` command, error: %s", err)
	end

	local i, tags = 1, {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		if i > #paths then
			break
		end
		tags[paths[i]] = tags[paths[i]] or {}

		local joint = line:match("\t(.+)$") or ""
		for s in joint:gmatch("[^,]+") do
			table.insert(tags[paths[i]], s)
		end
		i = i + 1
	end

	update(tags)
	return true
end



-- Get info about current folder and tagged files
local get_jump_info = ya.sync(function(st)
	local folder = cx.active.current
	local tagged_positions = {}
	
	-- Check each file in the visible window
	for i, file in ipairs(folder.window) do
		local url = tostring(file.url)
		-- Check against our stored tags
		if st.tags and st.tags[url] then
			for _, tag in ipairs(st.tags[url]) do
				if tag == "Red" then
					-- Store the position in the window (1-based)
					table.insert(tagged_positions, i)
					break
				end
			end
		end
	end
	
	return {
		positions = tagged_positions,
		cursor = folder.cursor,
		offset = folder.offset,
		window_size = #folder.window
	}
end)

local function entry(self, job)
	-- Add jump-next and jump-prev to valid actions
	local valid_actions = {"add", "remove", "toggle", "jump-next", "jump-prev"}
	local is_valid = false
	for _, action in ipairs(valid_actions) do
		if job.args[1] == action then
			is_valid = true
			break
		end
	end
	assert(is_valid, "Invalid action")
	
	-- Handle jump actions separately
	if job.args[1] == "jump-next" or job.args[1] == "jump-prev" then
		-- Get folder info and tagged positions
		-- Sync functions are called without passing self - state is automatic
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
		
		if job.args[1] == "jump-next" then
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
		return
	end
	
	ya.emit("escape", { visual = true })

	local action = job.args[1]
	
	-- For toggle, we need to check if files are already tagged
	if action == "toggle" then
		-- Get selected files
		local urls = selected_or_hovered()
		if #urls == 0 then
			return
		end
		
		-- Check if the first file is tagged by running the tag command
		local first_url = tostring(urls[1])
		local output = Command("tag"):arg("-l"):arg(first_url):output()
		local is_tagged = false
		
		if output and output.stdout then
			-- Check if "Red" tag is in the output
			is_tagged = string.find(output.stdout, "Red") ~= nil
		end
		
		-- If tagged, remove; if not tagged, add
		action = is_tagged and "remove" or "add"
	end

	-- Always use "Red" tag without asking
	local t = { action == "remove" and "-r" or "-a", "Red" }
	local files = {}
	for _, url in ipairs(selected_or_hovered()) do
		t[#t + 1] = tostring(url)
		files[#files + 1] = { url = url }
	end

	local status = Command("tag"):arg(t):status()
	if status.success then
		fetch(self, { files = files })
	end
end

return { setup = setup, fetch = fetch, entry = entry }
