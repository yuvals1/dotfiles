--- tag-fzf.yazi: Step 4 - Add tag filtering
local M = {}

-- Get current directory
local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

-- Get all tags in one batch call
local function get_all_tags_batch(file_paths)
	if #file_paths == 0 then
		return {}
	end
	
	-- Call tag command with all file paths at once
	local cmd = Command("tag"):arg("-l")
	for _, path in ipairs(file_paths) do
		cmd = cmd:arg(path)
	end
	
	local output = cmd:stdout(Command.PIPED):output()
	if not output then
		return {}
	end
	
	-- Parse output: each line is "filepath \t tag1,tag2,tag3"
	local tags_map = {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		-- Split by tab
		local path, tags_str = line:match("^(.+)\t(.+)$")
		if path and tags_str then
			local tags = {}
			for tag in tags_str:gmatch("[^,]+") do
				local clean = tag:gsub("^%s+", ""):gsub("%s+$", "")
				if #clean > 0 then
					tags[#tags + 1] = clean
				end
			end
			if #tags > 0 then
				tags_map[path] = tags
			end
		elseif not line:match("\t") then
			-- File has no tags (line is just the filepath)
			-- Skip it
		end
	end
	
	return tags_map
end

-- Get all files recursively using find command
local function get_all_files_recursive(cwd)
	local output = Command("find")
		:arg(cwd)
		:arg("-type")
		:arg("f")
		:stdout(Command.PIPED)
		:output()
	
	if not output then
		return {}
	end
	
	local files = {}
	for path in output.stdout:gmatch("[^\r\n]+") do
		files[#files + 1] = path
	end
	
	return files
end

function M:entry(job)
	ya.emit("escape", { visual = true })
	local _permit = ui.hide()
	
	-- Get current directory
	local cwd = get_cwd()
	
	-- Check if we have a tag filter argument
	local filter_tag = job.args and job.args[1] or nil
	if filter_tag then
		-- Normalize tag name (capitalize first letter)
		filter_tag = filter_tag:sub(1,1):upper() .. filter_tag:sub(2):lower()
	end
	
	-- Get all files recursively
	local all_files = get_all_files_recursive(cwd)
	
	-- Show progress
	ya.notify {
		title = "Tag-fzf",
		content = string.format("Scanning %d files for tags%s...", 
			#all_files, 
			filter_tag and string.format(" (filter: %s)", filter_tag) or ""),
		timeout = 1,
	}
	
	-- Get all tags in one batch call (MUCH faster!)
	local tags_map = get_all_tags_batch(all_files)
	
	-- Build tagged files list
	local tagged_files = {}
	for path, tags in pairs(tags_map) do
		-- If we have a filter, check if this file has the specified tag
		local include_file = true
		if filter_tag then
			include_file = false
			for _, tag in ipairs(tags) do
				if tag == filter_tag then
					include_file = true
					break
				end
			end
		end
		
		if include_file then
			local relative = path:sub(#cwd + 2)  -- Remove cwd and /
			if relative and #relative > 0 then
				tagged_files[#tagged_files + 1] = {
					name = relative,
					url = path,
					tags = tags,
					display = string.format("%-50s [%s]", relative, table.concat(tags, ","))
				}
			end
		end
	end
	
	-- If no tagged files, notify and return
	if #tagged_files == 0 then
		ya.notify {
			title = "Tag-fzf",
			content = filter_tag and 
				string.format("No files with '%s' tag found", filter_tag) or
				"No tagged files found in directory tree",
			timeout = 2,
			level = "warn"
		}
		return
	end
	
	-- Sort by path for better organization
	table.sort(tagged_files, function(a, b) return a.name < b.name end)
	
	-- Run fzf with tagged files
	-- Preview command: extract filename from the display string and prepend cwd
	local preview_cmd = string.format("echo {} | sed 's/ *\\[.*//g' | xargs -I%% bat --color=always --style=numbers '%s/%%'", cwd)
	
	local header = filter_tag and 
		string.format("Files with '%s' tag (TAB for multi-select)", filter_tag) or
		"Select tagged files (TAB for multi-select)"
	
	local child, err = Command("fzf")
		:arg("-m")  -- Multi-select
		:arg("--header=" .. header)
		:arg("--preview=" .. preview_cmd)
		:arg("--preview-window=right:50%")
		:stdin(Command.PIPED)
		:stdout(Command.PIPED)
		:cwd(cwd)
		:spawn()
	
	if not child then
		ya.notify {
			title = "Tag-fzf",
			content = "Failed to start fzf: " .. tostring(err),
			timeout = 3,
			level = "error"
		}
		return
	end
	
	-- Feed the file list to fzf
	for _, file in ipairs(tagged_files) do
		child:write_all(file.display .. "\n")
	end
	child:flush()
	
	-- Wait for fzf result
	local output, err = child:wait_with_output()
	if not output then
		ya.notify {
			title = "Tag-fzf",
			content = "Failed to read fzf output",
			timeout = 2,
			level = "error"
		}
		return
	end
	
	-- User cancelled with ESC
	if not output.status.success and output.status.code == 130 then
		return
	end
	
	-- Parse selected files
	local selected = {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		-- Find matching file by display string
		for _, file in ipairs(tagged_files) do
			if file.display == line then
				selected[#selected + 1] = Url(file.url)
				break
			end
		end
	end
	
	-- Handle selection
	if #selected == 1 then
		ya.emit("reveal", { selected[1], raw = true })
	elseif #selected > 1 then
		selected.state = "on"
		ya.emit("toggle_all", selected)
	end
end

return M