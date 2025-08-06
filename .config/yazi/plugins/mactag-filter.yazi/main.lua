--- Filter to show only files tagged with macOS Red tag
--- Depends on mactag-toggle plugin for tag state

return {
	entry = function(self, job)
		-- Apply filter using filter_do command (like filter-in plugin)
		-- For now, test with a simple pattern
		
		ya.manager_emit("filter_do", { "test" })
		
		ya.notify {
			title = "Tag Filter",
			content = "Applied filter for 'test'",
			timeout = 2,
		}
	end,
}