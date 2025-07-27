-- exclude-filter.yazi/main.lua
-- Step 2b: Get all files first, then filter

local get_all_files = ya.sync(function()
	local current = cx.active.current
	local files = {}
	if current and current.files then
		for _, file in ipairs(current.files) do
			table.insert(files, tostring(file.name))
		end
	end
	return files
end)

return {
	entry = function(self, job)
		local pattern = job.args[1] or "NO_ARG"
		
		-- Get all files
		local all_files = get_all_files()
		
		-- Filter them outside ya.sync
		local filtered = {}
		local excluded_count = 0
		
		for _, name in ipairs(all_files) do
			if not name:find(pattern, 1, true) then
				-- Escape special regex characters
				local escaped = name:gsub("([%.%[%]%(%)%+%-%*%?%^%$%{%}%|\\])", "\\%1")
				table.insert(filtered, escaped)
			else
				excluded_count = excluded_count + 1
			end
		end
		
		-- Apply the filter
		if #filtered > 0 then
			-- Build regex that matches any of these files exactly
			local regex = "^(" .. table.concat(filtered, "|") .. ")$"
			ya.manager_emit("filter_do", { regex })
		else
			-- No files to show
			ya.manager_emit("filter_do", { "^$" })
		end
	end,
}