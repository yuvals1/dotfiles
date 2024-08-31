# Error Handling and Logging in Yazi Lua Plugins

When developing plugins for Yazi, a file manager, it's crucial to handle errors gracefully and log them effectively. This guide explains a strategy for error handling and logging in Lua files for Yazi plugins.

## The Problem

Lua doesn't have built-in try-catch mechanisms, and errors can crash your plugin or the entire Yazi application. Additionally, some errors might occur silently, making debugging difficult.

## The Solution

We use a combination of Lua's `pcall` function and custom wrapper functions to catch errors and log them without crashing the plugin.

## Strategy Overview

1. Use a `safe_access` function to wrap potentially risky operations.
2. Employ `pcall` to catch errors.
3. Return meaningful error messages when something goes wrong.
4. Display errors in the Yazi notification system for visibility.

## Implementation

### Step 1: Create a Safe Access Function

```lua
local function safe_access(func, default)
    local success, result = pcall(func)
    if success then
        return result
    else
        return "Error: " .. tostring(result)
    end
end
```

This function takes two arguments:
- `func`: A function that might throw an error
- `default`: A default value to return if an error occurs (optional)

### Step 2: Use Safe Access in Your Code

Wrap potentially risky operations with `safe_access`:

```lua
local hovered_name = safe_access(function() 
    return hovered and hovered.name or "None" 
end, "Error")
```

### Step 3: Implement in Yazi Plugin

Here's an example of how to use this in a Yazi plugin:

```lua
local get_state = ya.sync(function()
    local tab = cx.active
    local current = tab.current
    local hovered = current.hovered

    return {
        cwd = safe_access(function() return tostring(current.cwd) end, "Unknown"),
        hovered = safe_access(function() return hovered and hovered.name or "None" end, "Error"),
        hovered_modified = safe_access(function()
            if hovered and hovered.cha.modified then
                return os.date("%Y-%m-%d %H:%M:%S", hovered.cha.modified)
            end
            return "N/A"
        end, "Error"),
        -- ... other state properties ...
    }
end)
```

### Step 4: Display Errors in Yazi Notifications

Use Yazi's notification system to display the state, including any errors:

```lua
local function info(content)
    return ya.notify({
        title = "Yazi State",
        content = content,
        timeout = 10,
    })
end

-- In your plugin's entry function:
local state = get_state()
if not state then
    return info("Unable to get Yazi state")
end

local content = string.format(
    "CWD: %s\nHovered: %s\nHovered Modified: %s",
    state.cwd,
    state.hovered,
    state.hovered_modified
)
info(content)
```

## Benefits of This Approach

1. **Graceful Error Handling**: Your plugin won't crash when encountering errors.
2. **Visibility**: Errors are displayed in Yazi's notification system, making them easy to spot.
3. **Detailed Information**: You get specific error messages for each problematic operation.
4. **Easy Debugging**: Helps identify which parts of your plugin are causing issues.

## Conclusion

By implementing this error handling and logging strategy, you can create more robust and debuggable Yazi plugins. This approach helps you identify and fix issues quickly, improving the overall stability and user experience of your plugins.
