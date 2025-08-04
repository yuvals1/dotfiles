-- Kitty icat viewer plugin - Final working version
local selected_or_hovered = ya.sync(function()
    local tab, paths = cx.active, {}
    
    -- Get selected files
    for _, u in pairs(tab.selected) do
        paths[#paths + 1] = tostring(u)
    end
    
    -- Sort paths to ensure consistent order
    table.sort(paths)
    
    -- If no selection, use hovered
    if #paths == 0 and tab.current.hovered then
        paths[1] = tostring(tab.current.hovered.url)
    end
    
    return paths
end)

local function is_image(path)
    local ext = path:match("%.([^.]+)$")
    if not ext then return false end
    ext = ext:lower()
    
    local image_exts = {
        jpg = true, jpeg = true, png = true, gif = true,
        bmp = true, webp = true, ico = true, svg = true,
        tiff = true, tif = true, heic = true, heif = true
    }
    
    return image_exts[ext] == true
end

return {
    entry = function()
        local files = selected_or_hovered()
        
        if #files == 0 then
            return ya.notify {
                title = "Kitty View",
                content = "No files selected or hovered",
                timeout = 2,
                level = "warn"
            }
        end
        
        -- Filter only image files
        local images = {}
        for _, path in ipairs(files) do
            if is_image(path) then
                images[#images + 1] = path
            end
        end
        
        if #images == 0 then
            return ya.notify {
                title = "Kitty View",
                content = "No image files found",
                timeout = 2,
                level = "warn"
            }
        end
        
        -- Show info for multiple images
        if #images > 1 then
            local filename = images[1]:match("[^/]+$") or images[1]
            ya.notify {
                title = "Kitty View",
                content = string.format("Showing image 1/%d: %s", #images, filename),
                timeout = 2,
                level = "info"
            }
        end
        
        -- Create command to show all images in sequence
        local cmd = "echo 'Selected images in order:'"
        for i, image in ipairs(images) do
            local filename = image:match("[^/]+$") or image
            cmd = cmd .. " && echo '" .. i .. ". " .. filename .. "'"
        end
        
        -- Display each image in sequence
        for i, image in ipairs(images) do
            local filename = image:match("[^/]+$") or image
            cmd = cmd .. " && echo ''"
            cmd = cmd .. " && echo 'Displaying image " .. i .. "/" .. #images .. ": " .. filename .. "'"
            cmd = cmd .. " && kitty +kitten icat \"" .. image .. "\""
            
            if i < #images then
                cmd = cmd .. " && echo '' && echo 'Press Enter for next image...' && read"
                cmd = cmd .. " && kitty +kitten icat --clear"
            else
                cmd = cmd .. " && echo '' && echo 'Press Enter to return to yazi...' && read"
            end
        end
        
        -- Execute the command
        ya.emit("shell", {
            cmd,
            confirm = false,
            block = true,
        })
    end,
}