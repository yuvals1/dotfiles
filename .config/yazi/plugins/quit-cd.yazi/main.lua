local write_cwd_and_quit = ya.sync(function()
    local cwd = tostring(cx.active.current.cwd)
    local cd_file = os.getenv("YAZI_CD_FILE")
    if cd_file and cd_file ~= "" then
        local file = io.open(cd_file, "w")
        if file then
            file:write(cwd)
            file:close()
        end
    end
    ya.emit("quit", {})
end)

return {
    entry = function()
        write_cwd_and_quit()
    end,
}
