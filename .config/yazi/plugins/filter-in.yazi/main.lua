-- hardcoded-filter.yazi/main.lua
-- Plugin to apply a hardcoded filter

return {
	entry = function(self, job)
		local filter_text = job.args[1] or "hello"
		ya.manager_emit("filter_do", { filter_text })
	end,
}