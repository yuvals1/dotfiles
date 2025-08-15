-- Calendar jump plugin - jump directly to today's calendar folder

local function get_today_path()
    -- Get today's date components
    local today = os.date("%Y-%m-%d")
    local day_of_week = os.date("%a")
    
    -- Construct the full path with day suffix
    local calendar_base = os.getenv("HOME") .. "/personal/calendar/days"
    local today_folder = today .. "[" .. day_of_week .. "]"
    
    return calendar_base .. "/" .. today_folder
end

return {
    entry = function(_, job)
        local action = job.args[1] or "today"
        
        if action == "today" then
            local target_path = get_today_path()
            
            -- Emit cd command to jump to today's folder
            ya.manager_emit("cd", { target_path })
            
            -- Optional: Show notification
            ya.notify {
                title = "Calendar Jump",
                content = "Jumped to " .. os.date("%B %d, %Y"),
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