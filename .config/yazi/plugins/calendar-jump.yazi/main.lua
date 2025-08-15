-- Calendar jump plugin - jump directly to today's calendar folder

-- Sync function to find today's folder index
local find_today_index = ya.sync(function()
    local today = os.date("%Y-%m-%d")
    local cur = cx.active.current
    local files = cur.files
    
    -- Find the folder that starts with today's date
    for i = 1, #files do
        local name = files[i].name
        if name and tostring(name):sub(1, 10) == today then
            return i - cur.cursor - 1  -- Return delta from current position (0-based)
        end
    end
    
    return nil
end)

return {
    entry = function(_, job)
        local action = job.args[1] or "today"
        
        if action == "today" then
            -- First navigate to the calendar days directory
            local calendar_days = os.getenv("HOME") .. "/personal/calendar/days"
            ya.manager_emit("cd", { calendar_days })
            
            -- Then find and hover on today's folder
            local delta = find_today_index()
            if delta then
                ya.manager_emit("arrow", { delta })
            end
            
            -- Optional: Show notification
            ya.notify {
                title = "Calendar Jump",
                content = "Focused on " .. os.date("%B %d, %Y"),
                timeout = 1,
            }
        elseif action == "calendar" then
            -- Jump to calendar root
            local calendar_root = os.getenv("HOME") .. "/personal/calendar/days"
            ya.manager_emit("cd", { calendar_root })
            
            ya.notify {
                title = "Calendar Jump",
                content = "Jumped to calendar",
                timeout = 1,
            }
        end
    end
}