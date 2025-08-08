--- Unified macOS tag management plugin

-- Module table so other plugins can read current tags via
-- `package.loaded["mactag-unified"].tags`
local M = {
    tags = {},
}

-- Our managed tag set (mutually exclusive)
local MANAGED_TAGS = {
    ["red"] = "Red",
    ["done"] = "Done",
    ["x"] = "X",
    ["sleep"] = "Sleep",
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
                elseif tag == "X" then
                    return ui.Line { ui.Span("❌ "), original }
                elseif tag == "Sleep" then
                    return ui.Line { ui.Span("💤 "), original }
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
            table.insert(tags[paths[i]], s)
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

local function apply_tag(paths, tag_key)
    -- Remove all managed tags first
    if #paths == 0 then return end
    local remove_cmd = Command("tag")
    remove_cmd = remove_managed_tags_from(remove_cmd)
    for _, p in ipairs(paths) do remove_cmd = remove_cmd:arg(p) end
    remove_cmd:status()

    -- Add new tag if requested and not "none"
    local tag_name = tag_key and MANAGED_TAGS[tag_key] or nil
    if tag_name then
        local add_cmd = Command("tag"):arg("-a"):arg(tag_name)
        for _, p in ipairs(paths) do add_cmd = add_cmd:arg(p) end
        add_cmd:status()
    end

    -- Update visual state immediately
    local tags_update = {}
    for _, p in ipairs(paths) do
        if tag_name then
            tags_update[p] = { tag_name }
        else
            tags_update[p] = {}
        end
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