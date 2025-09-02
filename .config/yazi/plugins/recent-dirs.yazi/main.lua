local state = ya.sync(function(st)
	return {
		cwd = tostring(cx.active.current.cwd),
		empty = st.empty,
	}
end)

local set_state = ya.sync(function(st, empty) st.empty = empty end)

local function fail(s, ...) ya.notify { title = "Recent Dirs", content = s:format(...), timeout = 5, level = "error" } end

local function options()
	-- https://github.com/ajeetdsouza/zoxide/blob/main/src/cmd/query.rs#L92
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
			default[#default + 1] = [[--preview='\command -p ls -Cp --color=always --group-directories-first {}']]
		else
			default[#default + 1] = [[--preview='\command -p ls -Cp {}']]
		end
	end

	return (os.getenv("FZF_DEFAULT_OPTS") or "")
		.. " "
		.. table.concat(default, " ")
		.. " "
		.. (os.getenv("YAZI_RECENT_DIRS_OPTS") or "")
end

local function get_recent_dirs(cwd)
	-- Hardcoded 5 directories for testing
	local dirs = {
		"/Users/yuvalspiegel/dotfiles/.config",
		"/Users/yuvalspiegel/personal/calendar/days",
		"/Users/yuvalspiegel/dev/yazi",
		"/Users/yuvalspiegel/personal/tasks",
		"/Users/yuvalspiegel/Downloads"
	}
	
	-- Filter out current directory
	local filtered = {}
	for _, dir in ipairs(dirs) do
		if dir ~= cwd then
			filtered[#filtered + 1] = dir
		end
	end
	
	return filtered
end

local function setup(_, opts)
	opts = opts or {}

	if opts.update_db then
		ps.sub(
			"cd",
			function()
				ya.emit("shell", {
					cwd = fs.cwd(),
					orphan = true,
					"zoxide add " .. ya.quote(tostring(cx.active.current.cwd)),
				})
			end
		)
	end
end

local function entry()
	local st = state()
	local dirs = get_recent_dirs(st.cwd)
	
	if #dirs == 0 then
		return fail("No recent directories available")
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