-- plugins/show-cwd.yazi/init.lua

local get_cwd = ya.sync(function()
	return cx.active.current.cwd
end)

local function info(content)
	return ya.notify({
		title = "Current Working Directory",
		content = content,
		timeout = 5,
	})
end

return {
	entry = function()
		local cwd = get_cwd()
		if not cwd then
			return info("Unable to get current working directory")
		end
		info(tostring(cwd))
	end,
}
