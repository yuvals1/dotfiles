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

-- Helper to get current tab index and per-tab history state
local get_tab_and_history = ya.sync(function(state)
  return cx.tabs.idx, state.tabhist
end)

-- Ensure per-tab list exists (utility to be called from setup only)
local ensure_list = function(tabhist, tab)
  if not tabhist[tab] then tabhist[tab] = {} end
  return tabhist[tab]
end

local function get_recent_dirs(cwd)
	local tab, hist = get_tab_and_history()
	hist = hist or {}
	local list = hist[tab] or {}
	
	-- Filter out current directory
	local filtered = {}
	for _, dir in ipairs(list) do
		if dir ~= cwd then
			filtered[#filtered + 1] = dir
		end
	end
	
	return filtered
end

local function setup(state)
	state.tabhist = state.tabhist or {}

	ps.sub('cd', function(body)
		local tab = body.tab or cx.tabs.idx
		local cwd = tostring(cx.active.current.cwd)

		local tabhist = state.tabhist
		local list = ensure_list(tabhist, tab)

		-- Remove any existing occurrence of this cwd
		for i = #list, 1, -1 do
			if list[i] == cwd then table.remove(list, i) end
		end
		-- Add to front
		table.insert(list, 1, cwd)
		-- Cap at 5 items
		while #list > 5 do table.remove(list) end
	end)
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