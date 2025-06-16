--- Git VCS Files including untracked files

local root = ya.sync(function() return cx.active.current.cwd end)

local function fail(content) return ya.notify { title = "VCS Files", content = content, timeout = 5, level = "error" } end

local function entry()
	local root = root()
	-- Get both tracked modified files and untracked files
	local output, err = Command("git"):cwd(tostring(root)):arg({ "status", "--porcelain", "-uall" }):output()
	if err then
		return fail("Failed to run `git status`, error: " .. err)
	elseif not output.status.success then
		return fail("Failed to run `git status`, stderr: " .. output.stderr)
	end

	local id = ya.id("ft")
	local cwd = root:into_search("Git changes (all)")
	ya.emit("cd", { Url(cwd) })
	ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(cwd), files = {} }) })

	local files = {}
	local seen = {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		-- Extract filename from git status porcelain output
		-- Format: XY filename (where X and Y are status codes)
		local filename = line:match("^.. (.+)$")
		if filename and not seen[filename] then
			seen[filename] = true
			local url = cwd:join(filename)
			local cha = fs.cha(url, true)
			if cha then
				files[#files + 1] = File { url = url, cha = cha }
			end
		end
	end
	ya.emit("update_files", { op = fs.op("part", { id = id, url = Url(cwd), files = files }) })
	ya.emit("update_files", { op = fs.op("done", { id = id, url = cwd, cha = Cha { kind = 16 } }) })
end

return { entry = entry }