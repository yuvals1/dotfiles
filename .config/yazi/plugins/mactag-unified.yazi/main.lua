--- Unified macOS tag management plugin
--- Step 2: Add visual display logic

-- Update state and trigger render
local update = ya.sync(function(st, tags)
	for path, tag in pairs(tags) do
		st.tags[path] = #tag > 0 and tag or nil
	end
	-- Trigger render
	if ui.render then
		ui.render()
	else
		ya.render()
	end
end)

-- Setup function to initialize visual display
local function setup(st, opts)
	st.tags = {}
	
	-- Save the original icon function
	st.original_icon = Entity.icon
	
	-- Override the icon function to show visual indicators
	Entity.icon = function(self)
		-- Get the original icon
		local original = st.original_icon(self)
		
		-- Get the file URL
		local url = tostring(self._file.url)
		
		-- Check if this file has tags
		local file_tags = st.tags[url]
		
		if file_tags then
			for _, tag in ipairs(file_tags) do
				if tag == "Done" then
					-- File is done - add checkmark emoji before icon
					local done_emoji = ui.Span("✅ ")
					return ui.Line { done_emoji, original }
				elseif tag == "Red" then
					-- File is tagged with Red - add red dot before icon
					local red_dot = ui.Span("● "):fg("#ee7b70")
					return ui.Line { red_dot, original }
				end
			end
		end
		
		-- File is not tagged - show original icon only
		return original
	end
end

-- Fetch tags from macOS tag command
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

local function entry(_, job)
	-- Get the command (first argument)
	local command = job.args[1]
	
	if command == "toggle" then
		ya.notify {
			title = "Mactag Unified",
			content = "Toggle command called",
			timeout = 2,
		}
	elseif command == "rotate" then
		ya.notify {
			title = "Mactag Unified", 
			content = "Rotate command called",
			timeout = 2,
		}
	else
		ya.notify {
			title = "Mactag Unified",
			content = "Unknown command: " .. (command or "nil"),
			timeout = 2,
			level = "warn",
		}
	end
end

return { setup = setup, fetch = fetch, entry = entry }