-- Set current file/folder as active task

local function entry()
	local h = cx.active.current.hovered
	if not h then
		ya.notify { title = "Set Task", content = "No file selected", timeout = 2, level = "warn" }
		return
	end
	
	local selected = tostring(h.url)
	-- Use ya.manager_emit to run shell command
	ya.manager_emit("shell", {
		"~/.config/sketchybar/task-link set '" .. selected .. "'",
		confirm = true,
	})
end

return { entry = entry }