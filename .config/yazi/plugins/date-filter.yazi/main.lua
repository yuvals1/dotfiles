-- Date filter plugin for calendar navigation

-- Get today's date in YYYY-MM-DD format
local function get_today()
    return os.date("%Y-%m-%d")
end

-- Get pattern for current week
local function get_current_week_pattern()
    local today = os.time()
    local weekday = tonumber(os.date("%w", today))  -- 0 = Sunday
    
    -- Calculate start of week (Sunday)
    local week_start = today - (weekday * 86400)
    local week_end = week_start + (6 * 86400)
    
    -- Get the date range
    local start_day = tonumber(os.date("%d", week_start))
    local end_day = tonumber(os.date("%d", week_end))
    local month = os.date("%Y-%m", today)
    
    -- Handle week spanning months
    if end_day < start_day then
        -- Week spans two months, just show all of current month for simplicity
        return "^" .. month .. "-"
    end
    
    -- Build regex for day range (e.g., for days 11-17: "(1[1-7])")
    if end_day - start_day == 6 then
        -- Normal week within single month
        local tens = math.floor(start_day / 10)
        local start_ones = start_day % 10
        local end_ones = end_day % 10
        
        if math.floor(end_day / 10) == tens then
            -- Same tens digit (e.g., 11-17 or 21-27)
            return string.format("^%s-(%d[%d-%d])", month, tens, start_ones, end_ones)
        else
            -- Spans tens (e.g., 07-13 or 28-31)
            -- For simplicity, match broader range
            return string.format("^%s-(0[%d-9]|1[0-%d])", month, start_ones, end_ones)
        end
    end
    
    -- Fallback to current month
    return "^" .. month .. "-"
end

-- Get pattern for week ahead (next 7 days from today)
local function get_week_ahead_pattern()
    local today = os.time()
    local dates = {}
    
    -- Collect the next 7 days including today
    for i = 0, 6 do
        local day = today + (i * 86400)
        local date_str = os.date("%Y-%m-%d", day)
        table.insert(dates, date_str)
    end
    
    -- Build regex pattern that matches any of these dates
    -- Format: (2025-08-15|2025-08-16|...|2025-08-21)
    local pattern = "^(" .. table.concat(dates, "|") .. ")"
    return pattern
end

-- Get pattern for two weeks ahead (next 14 days from today)
local function get_two_weeks_ahead_pattern()
    local today = os.time()
    local dates = {}
    
    -- Collect the next 14 days including today
    for i = 0, 13 do
        local day = today + (i * 86400)
        local date_str = os.date("%Y-%m-%d", day)
        table.insert(dates, date_str)
    end
    
    -- Build regex pattern that matches any of these dates
    local pattern = "^(" .. table.concat(dates, "|") .. ")"
    return pattern
end

-- Get pattern for current month
local function get_current_month_pattern()
    return "^" .. os.date("%Y-%m") .. "-"
end

-- Get pattern for current year
local function get_current_year_pattern()
    return "^" .. os.date("%Y") .. "-"
end

-- Apply filter to yazi
local function apply_filter(pattern)
    ya.manager_emit("filter_do", { pattern })
end

-- Entry point
return {
    entry = function(_, job)
        local action = job.args[1]
        
        if action == "today" then
            local pattern = "^" .. get_today()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter",
                content = "Filtering: Today",
                timeout = 1,
            }
        elseif action == "week" then
            local pattern = get_current_week_pattern()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter", 
                content = "Filtering: This week",
                timeout = 1,
            }
        elseif action == "week-ahead" then
            local pattern = get_week_ahead_pattern()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter",
                content = "Filtering: Next 7 days",
                timeout = 1,
            }
        elseif action == "twoweeks-ahead" then
            local pattern = get_two_weeks_ahead_pattern()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter",
                content = "Filtering: Next 14 days",
                timeout = 1,
            }
        elseif action == "month" then
            local pattern = get_current_month_pattern()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter",
                content = "Filtering: " .. os.date("%B %Y"),
                timeout = 1,
            }
        elseif action == "year" then
            local pattern = get_current_year_pattern()
            apply_filter(pattern)
            ya.notify {
                title = "Date Filter",
                content = "Filtering: " .. os.date("%Y"),
                timeout = 1,
            }
        end
    end
}
