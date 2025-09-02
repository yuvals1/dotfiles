local state = ya.sync(function(st)
	return {
		cwd = tostring(cx.active.current.cwd),
	}
end)

local function fail(tag, s, ...) ya.notify { title = tag .. " Dirs", content = s:format(...), timeout = 5, level = "error" } end

local function options()
	local default = {
		-- Search mode
		"--exact",
		-- Search result
		"--no-sort",
		-- Interface
		"--bind=ctrl-z:ignore,btab:up,tab:down",
		"--cycle",
		"--keep-right",
		-- Layout
		"--layout=reverse",
		"--height=100%",
		"--border",
		"--scrollbar=▌",
		"--info=inline",
		-- Display
		"--tabstop=1",
		-- Scripting
		"--exit-0",
	}

	if ya.target_family() == "unix" then
		default[#default + 1] = "--preview-window=down,30%,sharp"
		if ya.target_os() == "linux" then
			default[#default + 1] = [[--preview='if [ -d {} ]; then \command -p ls -Cp --color=always --group-directories-first {}; else bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"; fi']]
		else
			default[#default + 1] = [[--preview='if [ -d {} ]; then \command -p ls -Cp {}; else bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"; fi']]
		end
	end

	return (os.getenv("FZF_DEFAULT_OPTS") or "")
		.. " "
		.. table.concat(default, " ")
		.. " "
		.. (os.getenv("YAZI_PURPLE_DIRS_OPTS") or "")
end

local function get_tagged_dirs(cwd, tag)
	-- Use mdfind to search for tagged directories
	local query = "kMDItemUserTags == '" .. tag .. "'"
	local child = Command("mdfind")
		:arg("-onlyin")
		:arg(os.getenv("HOME"))
		:arg(query)
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		return {}
	end

	local output, err = child:wait_with_output()
	if not output or not output.status.success then
		return {}
	end

	-- Parse directories and filter out current directory and calendar paths
	local dirs = {}
	for line in output.stdout:gmatch("[^\r\n]+") do
		local dir = line:gsub("^%s+", ""):gsub("%s+$", "")
		if #dir > 0 and dir ~= cwd and not dir:match("^/Users/yuvalspiegel/personal/calendar") then
			dirs[#dirs + 1] = dir
		end
	end

	return dirs
end

local function setup(state)
	-- No setup needed for purple dirs - we search on demand
end

local function entry(_, job)
	local tag = job.args[1] or "Purple"
	local st = state()
	local dirs = get_tagged_dirs(st.cwd, tag)
	
	if #dirs == 0 then
		return fail(tag, "No %s-tagged directories found", tag)
	end

	local _permit = ui.hide()
	local child, err = Command("fzf")
		:env("SHELL", "sh")
		:env("CLICOLOR", 1)
		:env("CLICOLOR_FORCE", 1)
		:env("FZF_DEFAULT_OPTS", options())
		:stdin(Command.PIPED)
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		return fail("Failed to start `fzf`, error: %s", err)
	end

	for _, dir in ipairs(dirs) do
		child:write_all(string.format("%s\n", dir))
	end
	child:flush()

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `fzf` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end
	
	local target = output.stdout:gsub("\n$", "")
	if target ~= "" then
		ya.emit("cd", { target, raw = true })
	end
end

return { setup = setup, entry = entry }