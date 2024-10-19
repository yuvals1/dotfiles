local paths = { "config", "data", "cache", "state" }
for _, path_type in ipairs(paths) do
	print(path_type .. ": " .. vim.fn.stdpath(path_type))
end
