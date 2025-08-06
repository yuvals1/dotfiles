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

	-- Keep the linemode for now (can be removed later)
	Linemode:children_add(function(self)
		local url = tostring(self._file.url)
		local spans = {}
		for _, tag in ipairs(st.tags[url] or {}) do
			-- Only show red tags
			if tag == "Red" then
				if self._file.is_hovered then
					spans[#spans + 1] = ui.Span(" ●"):bg(st.red_color)
				else
					spans[#spans + 1] = ui.Span(" ●"):fg(st.red_color)
				end
			end
		end
		return ui.Line(spans)
	end, 500)
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

local function entry(self, job)
	assert(job.args[1] == "add" or job.args[1] == "remove", "Invalid action")
	ya.emit("escape", { visual = true })

	-- Always use "Red" tag without asking
	local t = { job.args[1] == "remove" and "-r" or "-a", "Red" }
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
