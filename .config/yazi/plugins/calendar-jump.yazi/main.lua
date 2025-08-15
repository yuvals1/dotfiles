-- Calendar jump plugin - jump directly to today's calendar folder

return {
    entry = function(_, job)
        local action = job.args[1] or "today"
        
        if action == "today" then
            -- Get today's date
            local today = os.date("%Y-%m-%d")
            local weekday_num = tonumber(os.date("%w"))  -- 0=Sunday
            
            -- Build the exact folder name with new format
            local suffix
            if weekday_num == 0 then
                suffix = "  (Sunday)"
            else
                suffix = "  (" .. (weekday_num + 1) .. ")"
            end
            
            -- Construct full path
            local calendar_days = os.getenv("HOME") .. "/personal/calendar/days"
            local today_path = calendar_days .. "/" .. today .. suffix
            
            -- Use reveal with exact path - this works reliably
            ya.manager_emit("reveal", { today_path })
            
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