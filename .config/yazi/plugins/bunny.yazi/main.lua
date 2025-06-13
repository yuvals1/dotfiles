--- @since 25.5.28
local function debug(...)
  local function toReadableString(val)
    if type(val) == "table" then
      local str = "{ "
      for k, v in pairs(val) do
        str = str .. "[" .. tostring(k) .. "] = " .. toReadableString(v) .. ", "
      end
      return str .. "}"
    elseif type(val) == "Url" then
      return "Url:" .. tostring(val)
    else
      return tostring(val)
    end
  end
  local args = { ... }
  local processed_args = {}
  for _, arg in pairs(args) do
    table.insert(processed_args, toReadableString(arg))
  end
  ya.dbg("BUNNY.YAZI", table.unpack(processed_args))
end

local function fail(s, ...) ya.notify { title = "bunny.yazi", content = string.format(s, ...), timeout = 4, level = "error" } end
local function info(s, ...) ya.notify { title = "bunny.yazi", content = string.format(s, ...), timeout = 2, level = "info" } end

local get_state = ya.sync(function(state, attr)
  return state[attr]
end)

local set_state = ya.sync(function(state, attr, value)
  state[attr] = value
end)

local get_cwd = ya.sync(function(state)
  return tostring(cx.active.current.cwd)
end)

local get_hovered = ya.sync(function(state)
  local hovered = cx.active.current.hovered
  if hovered then
    return tostring(hovered.url), hovered.cha.is_dir
  end
  return nil, false
end)

local get_current_tab_idx = ya.sync(function(state)
  return cx.tabs.idx
end)

local get_tabs_as_paths = ya.sync(function(state)
  local tabs = cx.tabs
  local active_tab_idx = tabs.idx
  local result = {}
  for idx = 1, #tabs, 1 do
    if idx ~= active_tab_idx and tabs[idx] then
      result[idx] = tostring(tabs[idx].current.cwd)
    end
  end
  return result
end)

local function filename(pathstr)
  if pathstr == "/" then return pathstr end
  local url_name = Url(pathstr):name()
  if url_name then
    return tostring(url_name)
  else
    return pathstr
  end
end

local function path_to_desc(path, strategy)
  if strategy == "filename" then
    return filename(path)
  end
  local home = os.getenv("HOME")
  if home and home ~= "" then
    local startPos, endPos = string.find(path, home)
    if startPos == 1 then
      return "~" .. path:sub(endPos + 1)
    end
  end
  return tostring(path)
end

-- Load hops from single history file
local function load_hops()
  local home = os.getenv("HOME")
  if not home then return {} end
  
  local history_file = home .. "/.local/share/yazi/bunny-history.json"
  local file = io.open(history_file, "r")
  if not file then return {} end
  
  local content = file:read("*all")
  file:close()
  
  -- Simple JSON parsing for our use case
  local hops = {}
  for path, timestamp, count, desc in string.gmatch(content, '"([^"]+)":%s*{%s*"last_used":%s*(%d+),%s*"count":%s*(%d+),%s*"desc":%s*"([^"]*)"') do
    hops[path] = {
      last_used = tonumber(timestamp),
      count = tonumber(count),
      desc = desc ~= "" and desc or nil
    }
  end
  return hops
end

-- Save hops to single history file
local function save_hops(hops)
  local home = os.getenv("HOME")
  if not home then return end
  
  -- Ensure directory exists
  os.execute("mkdir -p " .. home .. "/.local/share/yazi")
  
  local history_file = home .. "/.local/share/yazi/bunny-history.json"
  local file = io.open(history_file, "w")
  if not file then return end
  
  -- Simple JSON generation
  file:write("{\n")
  local first = true
  for path, data in pairs(hops) do
    if not first then file:write(",\n") end
    first = false
    local desc = (data.desc or ""):gsub('"', '\\"')
    file:write(string.format('  "%s": {"last_used": %d, "count": %d, "desc": "%s"}', 
      path, data.last_used, data.count, desc))
  end
  file:write("\n}\n")
  file:close()
end

-- Save hovered directory as a hop
local function save_hovered_directory(config)
  local hovered_path, is_dir = get_hovered()
  local path_to_save = nil
  
  if hovered_path and is_dir then
    -- Save the hovered directory
    path_to_save = hovered_path
  elseif hovered_path and not is_dir then
    -- If hovering a file, save its parent directory
    local parent = Url(hovered_path):parent()
    if parent then
      path_to_save = tostring(parent)
    end
  end
  
  -- Fallback to current directory if nothing is hovered
  if not path_to_save then
    path_to_save = get_cwd()
  end
  
  local hops = load_hops()
  
  -- Update or create entry
  local existing = hops[path_to_save]
  hops[path_to_save] = {
    last_used = os.time(),
    count = existing and existing.count or 0,
    desc = existing and existing.desc or path_to_desc(path_to_save, config.desc_strategy)
  }
  
  save_hops(hops)
  info("Saved hop: " .. hops[path_to_save].desc)
end

-- Fuzzy search for deletion
local function delete_hop_fuzzy(config)
  local hops = load_hops()
  if next(hops) == nil then
    info("No saved hops to delete")
    return
  end
  
  local permit = ya.hide()
  
  -- Parse fuzzy command
  local cmd_parts = {}
  local in_quotes = false
  local current_part = ""
  local quote_char = nil
  
  for i = 1, #config.fuzzy_cmd do
    local char = config.fuzzy_cmd:sub(i, i)
    if (char == "'" or char == '"') and (not in_quotes or char == quote_char) then
      if not in_quotes then
        in_quotes = true
        quote_char = char
      else
        in_quotes = false
        quote_char = nil
      end
    elseif char == " " and not in_quotes then
      if current_part ~= "" then
        table.insert(cmd_parts, current_part)
        current_part = ""
      end
    else
      current_part = current_part .. char
    end
  end
  if current_part ~= "" then
    table.insert(cmd_parts, current_part)
  end
  
  -- Build command
  local cmd = Command(cmd_parts[1])
  for i = 2, #cmd_parts do
    cmd = cmd:arg(cmd_parts[i])
  end
  -- Add prompt for deletion
  cmd = cmd:arg("--prompt=Delete hop: ")
  
  local child, spawn_err = cmd:stdin(Command.PIPED):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
  if not child then
    permit:drop()
    fail("Command `%s` failed. Do you have it installed?", cmd_parts[1])
    return
  end
  
  -- Build input for fuzzy search
  local entries = {}
  for path, data in pairs(hops) do
    table.insert(entries, {
      path = path,
      desc = data.desc or path_to_desc(path, config.desc_strategy),
      last_used = data.last_used
    })
  end
  
  -- Sort by recency
  table.sort(entries, function(a, b)
    return a.last_used > b.last_used
  end)
  
  -- Build fuzzy input
  local input_lines = {}
  for _, entry in ipairs(entries) do
    local line = entry.desc .. string.rep(" ", 30 - #entry.desc) .. "\t" .. entry.path
    table.insert(input_lines, line)
  end
  
  child:write_all(table.concat(input_lines, "\n"))
  child:flush()
  local output, _ = child:wait_with_output()
  permit:drop()
  
  if not output.status.success then
    return -- User cancelled
  end
  
  -- Parse result
  local desc, path = string.match(output.stdout, "^(.-) *\t(.-)\n$")
  if path and path ~= "" then
    hops[path] = nil
    save_hops(hops)
    info("Deleted hop: " .. desc)
  end
end

-- Main fuzzy search and cd
local function fuzzy_search_and_cd(config)
  local hops = load_hops()
  local permit = ya.hide()
  
  -- Parse fuzzy command
  local cmd_parts = {}
  local in_quotes = false
  local current_part = ""
  local quote_char = nil
  
  for i = 1, #config.fuzzy_cmd do
    local char = config.fuzzy_cmd:sub(i, i)
    if (char == "'" or char == '"') and (not in_quotes or char == quote_char) then
      if not in_quotes then
        in_quotes = true
        quote_char = char
      else
        in_quotes = false
        quote_char = nil
      end
    elseif char == " " and not in_quotes then
      if current_part ~= "" then
        table.insert(cmd_parts, current_part)
        current_part = ""
      end
    else
      current_part = current_part .. char
    end
  end
  if current_part ~= "" then
    table.insert(cmd_parts, current_part)
  end
  
  -- Build command
  local cmd = Command(cmd_parts[1])
  for i = 2, #cmd_parts do
    cmd = cmd:arg(cmd_parts[i])
  end
  
  local child, spawn_err = cmd:stdin(Command.PIPED):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
  if not child then
    permit:drop()
    fail("Command `%s` failed. Do you have it installed?", cmd_parts[1])
    return
  end
  
  -- Build entries including special ones
  local entries = {}
  local special_entries = {}
  
  -- Add tab entries
  for idx, tab_path in pairs(get_tabs_as_paths()) do
    table.insert(special_entries, {
      path = tab_path,
      desc = "[Tab " .. idx .. "] " .. path_to_desc(tab_path, config.desc_strategy),
      is_special = true,
      sort_key = "0tab" .. idx
    })
  end
  
  -- Add back entry
  local tabhist = get_state("tabhist")
  local tab = get_current_tab_idx()
  if tabhist and tabhist[tab] and tabhist[tab][2] then
    local previous_dir = tabhist[tab][2]
    table.insert(special_entries, {
      path = previous_dir,
      desc = "[Back] " .. path_to_desc(previous_dir, config.desc_strategy),
      is_special = true,
      sort_key = "0back"
    })
  end
  
  -- Add hop entries
  for path, data in pairs(hops) do
    -- Check if directory still exists
    local _, err = fs.read_dir(Url(path), { limit = 1, resolve = true })
    if not err then
      table.insert(entries, {
        path = path,
        desc = data.desc or path_to_desc(path, config.desc_strategy),
        last_used = data.last_used,
        count = data.count,
        is_special = false
      })
    end
  end
  
  -- Sort hops by recency
  table.sort(entries, function(a, b)
    return a.last_used > b.last_used
  end)
  
  -- Combine special entries first, then regular entries
  local all_entries = {}
  for _, entry in ipairs(special_entries) do
    table.insert(all_entries, entry)
  end
  for _, entry in ipairs(entries) do
    table.insert(all_entries, entry)
  end
  
  -- Handle empty state
  if #all_entries == 0 then
    permit:drop()
    info("No saved hops. Use 'save' action to bookmark current directory")
    return
  end
  
  -- Build fuzzy input
  local input_lines = {}
  for _, entry in ipairs(all_entries) do
    local line = entry.desc .. string.rep(" ", 40 - #entry.desc) .. "\t" .. entry.path
    table.insert(input_lines, line)
  end
  
  child:write_all(table.concat(input_lines, "\n"))
  child:flush()
  local output, _ = child:wait_with_output()
  permit:drop()
  
  if not output.status.success then
    return -- User cancelled
  end
  
  -- Parse result
  local desc, path = string.match(output.stdout, "^(.-) *\t(.-)\n$")
  if not path or path == "" then
    return
  end
  
  -- Perform cd
  local _, dir_err = fs.read_dir(Url(path), { limit = 1, resolve = true })
  if dir_err then
    fail("Invalid directory: " .. path)
    return
  end
  
  ya.emit("cd", { path })
  
  -- Update usage for non-special entries
  local is_special = false
  for _, entry in ipairs(special_entries) do
    if entry.path == path then
      is_special = true
      break
    end
  end
  
  if not is_special and hops[path] then
    hops[path].last_used = os.time()
    hops[path].count = hops[path].count + 1
    save_hops(hops)
  end
  
  if config.notify then
    info("Hopped to: " .. path_to_desc(path, config.desc_strategy))
  end
end

local function validate_options(options)
  if type(options) ~= "table" then
    return "Invalid config"
  end
  
  local desc_strategy = options.desc_strategy
  local fuzzy_cmd = options.fuzzy_cmd
  local notify = options.notify
  
  if desc_strategy ~= nil and desc_strategy ~= "path" and desc_strategy ~= "filename" then
    return 'Invalid "desc_strategy" config value'
  elseif fuzzy_cmd ~= nil and type(fuzzy_cmd) ~= "string" then
    return 'Invalid "fuzzy_cmd" config value'
  elseif notify ~= nil and type(notify) ~= "boolean" then
    return 'Invalid "notify" config value'
  end
end

local function init()
  local options = get_state("options")
  local err = validate_options(options)
  if err then
    set_state("init_error", err)
    fail(err)
    return
  end
  
  -- Ensure history directory exists
  local home = os.getenv("HOME")
  if home then
    local history_dir = home .. "/.local/share/yazi"
    os.execute("mkdir -p " .. history_dir)
  end
  
  -- Set default config values
  local desc_strategy = options.desc_strategy or "path"
  
  -- Build default fuzzy command with history support
  local default_fuzzy_cmd = "fzf"
  if home and (not options.fuzzy_cmd or options.fuzzy_cmd == "fzf") then
    default_fuzzy_cmd = string.format(
      "fzf --history=%s/.local/share/yazi/bunny-fzf-history " ..
      "--history-size=1000 " ..
      "--algo=v2 " ..
      "--tiebreak=index " ..
      "--prompt='🐰 ' " ..
      "--pointer='→' " ..
      "--layout=reverse " ..
      "--info=inline " ..
      "--no-preview",
      home
    )
  end
  
  set_state("config", {
    desc_strategy = desc_strategy,
    fuzzy_cmd = options.fuzzy_cmd or default_fuzzy_cmd,
    notify = options.notify or false,
  })
  
  set_state("init", true)
end

return {
  setup = function(state, options)
    state.options = options or {}
    ps.sub("cd", function(body)
      local tab = body.tab
      local cwd = tostring(cx.active.current.cwd)
      local tabhist = state.tabhist or {}
      
      if not tabhist[tab] then
        tabhist[tab] = { cwd }
      else
        tabhist[tab] = { cwd, tabhist[tab][1] }
      end
      state.tabhist = tabhist
    end)
  end,
  entry = function(self, job)
    if not get_state("init") then
      init()
    end
    
    local init_error = get_state("init_error")
    if init_error then
      fail(init_error)
      return
    end
    
    local config = get_state("config")
    local action = job.args[1]
    
    if action == "save" then
      save_hovered_directory(config)
    elseif action == "delete" then
      delete_hop_fuzzy(config)
    else
      -- Default action: fuzzy search
      fuzzy_search_and_cd(config)
    end
  end,
}
