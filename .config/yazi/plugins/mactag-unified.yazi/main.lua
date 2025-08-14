--- Unified macOS tag management plugin

-- Module table so other plugins can read current tags via
-- `package.loaded["mactag-unified"].tags`
local M = {
    tags = {},
}

-- Our managed tag set (mutually exclusive)
local MANAGED_TAGS = {
    ["red"] = "Red",
    ["orange"] = "Orange",
    ["yellow"] = "Yellow",
    ["green"] = "Green",
    ["blue"] = "Blue",
    ["purple"] = "Purple",
    ["done"] = "Done",
    ["important"] = "Important",
    ["x"] = "X",
    ["sleep"] = "Sleep",
    ["point"] = "Point",
}

-- Update state and trigger render
local update = ya.sync(function(st, tags)
    for path, tag in pairs(tags) do
        st.tags[path] = #tag > 0 and tag or nil
        M.tags[path] = st.tags[path]
    end
    if ui.render then ui.render() else ya.render() end
end)

-- Setup function to initialize visual display
local function setup(st, _)
    st.tags = {}
    M.tags = st.tags

    -- Save the original icon function
    st.original_icon = Entity.icon

    -- Override the icon function to show visual indicators
    Entity.icon = function(self)
        local original = st.original_icon(self)
        local url = tostring(self._file.url)
        local file_tags = st.tags[url]
        if file_tags then
            for _, tag in ipairs(file_tags) do
                if tag == "Done" then
                    return ui.Line { ui.Span("✅ "), original }
                elseif tag == "Red" then
                    return ui.Line { ui.Span("● "):fg("#ee7b70"), original }
                elseif tag == "Orange" then
                    return ui.Line { ui.Span("● "):fg("#f5bd5c"), original }
                elseif tag == "Yellow" then
                    return ui.Line { ui.Span("● "):fg("#fbe764"), original }
                elseif tag == "Green" then
                    return ui.Line { ui.Span("● "):fg("#91fc87"), original }
                elseif tag == "Blue" then
                    return ui.Line { ui.Span("● "):fg("#5fa3f8"), original }
                elseif tag == "Purple" then
                    return ui.Line { ui.Span("● "):fg("#cb88f8"), original }
                elseif tag == "Important" then
                    return ui.Line { ui.Span("❗ "), original }
                elseif tag == "X" then
                    return ui.Line { ui.Span("❌ "), original }
                elseif tag == "Sleep" then
                    return ui.Line { ui.Span("⏸️ "), original }
                elseif tag == "Point" then
                    return ui.Line { ui.Span("👉 "), original }
                end
            end
        end
        return original
    end
end

-- Fetch tags from macOS tag command
local function fetch(_, job)
    local paths = {}
    for _, file in ipairs(job.files) do
        paths[#paths + 1] = tostring(file.url)
    end

    local output, err = Command("tag"):arg(paths):stdout(Command.PIPED):output()
    if not output then
        return true, Err("Cannot spawn `tag` command, error: %s", err)
    end

    local i, tags = 1, {}
    for line in output.stdout:gmatch("[^\r\n]+") do
        if i > #paths then break end
        tags[paths[i]] = tags[paths[i]] or {}
        local joint = line:match("\t(.+)$") or ""
        for s in joint:gmatch("[^,]+") do
            -- trim spaces around tag names and keep only managed tags
            local clean = s:gsub("^%s+", ""):gsub("%s+$", "")
            if #clean > 0 and MANAGED_TAGS[string.lower(clean)] then
                table.insert(tags[paths[i]], clean)
            end
        end
        i = i + 1
    end

    update(tags)
    return true
end

-- Helpers
local get_hovered = ya.sync(function()
    local tab = cx.active
    if tab.current.hovered then
        return tostring(tab.current.hovered.url)
    end
    return nil
end)

local get_selected_paths = ya.sync(function()
    local tab = cx.active
    local selected_paths = {}
    for _, url in pairs(tab.selected) do
        selected_paths[#selected_paths + 1] = tostring(url)
    end
    return selected_paths
end)

local function remove_managed_tags_from(cmd)
    for _, tag_name in pairs(MANAGED_TAGS) do
        cmd = cmd:arg("-r"):arg(tag_name)
    end
    return cmd
end

local function get_current_tags(path)
    -- Get current tags directly from macOS
    local output = Command("tag"):arg("-l"):arg(path):stdout(Command.PIPED):output()
    if not output then
        return {}
    end
    
    local tags = {}
    local line = output.stdout:gsub("^%s+", ""):gsub("%s+$", "")
    -- Parse the output: filename \t tag1,tag2,tag3
    local joint = line:match("\t(.+)$") or ""
    for s in joint:gmatch("[^,]+") do
        local clean = s:gsub("^%s+", ""):gsub("%s+$", "")
        if #clean > 0 then
            tags[#tags + 1] = clean
        end
    end
    return tags
end

local function apply_tag(paths, tag_key)
    -- Remove all managed tags first, per-file to avoid CLI quirks
    if #paths == 0 then return end

    local tag_name = tag_key and MANAGED_TAGS[tag_key] or nil

    for _, p in ipairs(paths) do
        -- Get current tags directly from the system
        local current = get_current_tags(p)
        local has_target = false
        local tags_to_remove = {}
        
        -- Check which managed tags need to be removed
        for _, t in ipairs(current) do
            local t_lower = string.lower(t)
            if t == tag_name then
                has_target = true
            elseif MANAGED_TAGS[t_lower] then
                -- This is a managed tag that needs to be removed
                tags_to_remove[#tags_to_remove + 1] = t
            end
        end
        
        -- Skip if already has the exact tag and no other managed tags
        if tag_name and has_target and #tags_to_remove == 0 then
            goto continue
        end
        
        -- Skip if clearing tags but no managed tags exist
        if not tag_name and #tags_to_remove == 0 then
            goto continue
        end

        -- Only remove the managed tags that actually exist
        for _, tname in ipairs(tags_to_remove) do
            Command("tag"):arg("-r"):arg(tname):arg(p):status()
        end
        
        -- Add new tag if requested and not already present
        if tag_name and not has_target then
            Command("tag"):arg("-a"):arg(tag_name):arg(p):status()
        end
        ::continue::
    end

    -- Update visual state by fetching actual tags after operation
    local tags_update = {}
    for _, p in ipairs(paths) do
        local new_tags = get_current_tags(p)
        local managed_only = {}
        for _, t in ipairs(new_tags) do
            if MANAGED_TAGS[string.lower(t)] then
                managed_only[#managed_only + 1] = t
            end
        end
        tags_update[p] = managed_only
    end
    update(tags_update)
end

local function entry(_, job)
    local action = (job.args[1] or ""):lower()
    local tag_key = nil
    if action == "none" or action == "clear" or action == "remove" then
        tag_key = nil
    elseif MANAGED_TAGS[action] then
        tag_key = action
    else
        ya.notify { title = "Mactag Unified", content = "Unknown action: " .. tostring(action), level = "warn", timeout = 2 }
        return
    end

    local selected = get_selected_paths()
    if #selected > 0 then
        -- Tag all selected and stay
        apply_tag(selected, tag_key)
    else
        -- Operate on hovered and jump down
        local hovered = get_hovered()
        if not hovered then
            ya.notify { title = "Mactag Unified", content = "No file hovered", timeout = 1 }
            return
        end
        apply_tag({ hovered }, tag_key)
        ya.manager_emit("arrow", { 1 })
    end
end
M.setup = setup
M.fetch = fetch
M.entry = entry
return M