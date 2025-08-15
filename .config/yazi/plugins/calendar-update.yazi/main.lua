-- Calendar update plugin - step by step approach

local function entry(_, job)
    -- Step 1: Show starting notification
    ya.notify {
        title = "Calendar Update",
        content = "Updating tags...",
        timeout = 1,
    }
    
    -- Step 2: Run daemon update (same pattern as mactag-unified uses for tag command)
    local output, err = Command("/Users/yuvalspiegel/dotfiles/.config/filecal/daemon.sh")
        :arg("update")
        :stdout(Command.PIPED)
        :output()
    
    if not output then
        ya.notify {
            title = "Calendar Update",
            content = "Failed: " .. (err or "unknown error"),
            level = "error",
            timeout = 3,
        }
        return
    end
    
    -- Show success
    ya.notify {
        title = "Calendar Update",
        content = "Daemon update completed!",
        timeout = 2,
    }
end

return { entry = entry }