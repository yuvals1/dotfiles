-- filter-rotate.yazi/main.lua
-- Plugin to rotate through emoji filters

-- Define the filter rotation order
local filters = {
	{ emoji = "✅", pattern = "✅", name = "done" },
	{ emoji = "❗", pattern = "❗", name = "important" },
	{ emoji = "💤", pattern = "💤", name = "waiting" },
	{ emoji = "❌", pattern = "❌", name = "cancelled" },
	{ emoji = nil, pattern = nil, name = "none" }  -- Clear filter state
}

-- State file to persist filter index
local state_file = os.getenv("HOME") .. "/.local/share/yazi/filter_rotate_state"

local function read_state()
	local file = io.open(state_file, "r")
	if not file then
		return 0
	end
	local index = tonumber(file:read("*a")) or 0
	file:close()
	return index
end

local function write_state(index)
	-- Ensure directory exists
	os.execute("mkdir -p " .. os.getenv("HOME") .. "/.local/share/yazi")
	local file = io.open(state_file, "w")
	if file then
		file:write(tostring(index))
		file:close()
	end
end

return {
	entry = function(self, job)
		-- Read current state
		local current_index = read_state()
		
		-- Rotate to the next filter
		current_index = (current_index % #filters) + 1
		
		-- Save new state
		write_state(current_index)
		
		local filter = filters[current_index]
		
		-- Apply the filter or clear it
		if filter.pattern then
			-- Apply the emoji filter
			ya.manager_emit("filter_do", { filter.pattern })
			
			-- Show notification about current filter
			ya.notify({
				title = "Filter",
				content = string.format("Filtering: %s %s", filter.emoji, filter.name),
				timeout = 2,
			})
		else
			-- Clear the filter (none state)
			ya.manager_emit("escape", { filter = true })
			
			-- Show notification about clearing filter
			ya.notify({
				title = "Filter",
				content = "Filter cleared",
				timeout = 2,
			})
			
			-- Reset state to 0 for next cycle
			write_state(0)
		end
	end,
}