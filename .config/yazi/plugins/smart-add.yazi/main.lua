--- Smart add: Create file/folder in hovered directory or CWD
local get_target_dir = ya.sync(function()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		return tostring(h.url)
	end
	return tostring(cx.active.current.cwd)
end)

return {
	entry = function()
		local target_dir = get_target_dir()
		
		local value, event = ya.input {
			title = "Create:",
			pos = { "top-center", y = 3, w = 40 },
		}
		
		if event ~= 1 or not value or value == "" then
			return
		end
		
		local target_path = target_dir .. "/" .. value
		
		-- Check if it's a directory (ends with /)
		if value:sub(-1) == "/" then
			-- Create directory
			local status = Command("mkdir"):arg("-p"):arg(target_path):spawn():wait()
			if not status or not status.success then
				ya.notify {
					title = "Create",
					content = "Failed to create directory",
					level = "error",
					timeout = 2,
				}
			else
				ya.notify {
					title = "Create",
					content = "Directory created: " .. value,
					timeout = 2,
				}
			end
		else
			-- Create file
			local status = Command("touch"):arg(target_path):spawn():wait()
			if not status or not status.success then
				ya.notify {
					title = "Create", 
					content = "Failed to create file",
					level = "error",
					timeout = 2,
				}
			else
				ya.notify {
					title = "Create",
					content = "File created: " .. value,
					timeout = 2,
				}
			end
		end
	end,
}