-- Configure git signs before setup
th = th or {}
th.git = {
	modified_sign = "M",
	added_sign = "A", 
	untracked_sign = "?",
	ignored_sign = "!",
	deleted_sign = "D",
	updated_sign = "U"
}

require('git'):setup {}
-- require('my_linemode'):setup()
require('full-border'):setup()
-- require('star_linemode'):setup()

-- Setup pref-by-location for remembering sort order
local pref_by_location = require("pref-by-location")
pref_by_location:setup({
  prefs = {
    -- Add location-specific preferences here if needed
  },
})

-- You can configure your bookmarks by lua language
local bookmarks = {}

local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == 'windows' and os.getenv 'USERPROFILE' or os.getenv 'HOME'
if ya.target_family() == 'windows' then
  table.insert(bookmarks, {
    tag = 'Scoop Local',

    path = (os.getenv 'SCOOP' or home_path .. '\\scoop') .. '\\',
    key = 'p',
  })
  table.insert(bookmarks, {
    tag = 'Scoop Global',
    path = (os.getenv 'SCOOP_GLOBAL' or 'C:\\ProgramData\\scoop') .. '\\',
    key = 'P',
  })
end

function Linemode:justname()
  return self._file.name
end

function Linemode:linecount()
  -- For directories, return empty
  if self._file.cha.is_dir then
    return ''
  end

  -- For files, count lines
  local path = tostring(self._file.url)
  local count = 0

  -- Try to open the file
  local file = io.open(path, 'r')
  if not file then
    return 'N/A'
  end

  -- Count lines
  for _ in file:lines() do
    count = count + 1
  end
  file:close()

  -- Format the output
  if count == 0 then
    return '0L'
  elseif count < 1000 then
    return count .. 'L'
  else
    -- Format thousands with K
    return string.format('%.1fK', count / 1000) .. 'L'
  end
end

function Linemode:recency()
  -- Get current time
  local current_time = os.time()
  
  -- Get file modification time
  local mtime = self._file.cha.mtime
  if not mtime then
    return ''
  end
  
  -- Calculate difference in seconds
  local diff = current_time - mtime
  
  -- Handle files with future timestamps (just created)
  if diff < 0 then
    return '•0d'
  end
  
  -- Convert to days
  local days = math.floor(diff / 86400)
  
  if days == 0 then
    return '•0d'
  else
    return days .. 'd'
  end
end

function Linemode:age()
  -- Get file birth/creation time
  local btime = self._file.cha.btime
  if not btime then
    return ''
  end
  
  -- Get current time
  local current_time = os.time()
  
  -- Calculate difference in seconds
  local diff = current_time - btime
  
  -- Handle files with future timestamps
  if diff < 0 then
    return '0d'
  end
  
  -- Convert to days
  local days = math.floor(diff / 86400)
  
  if days == 0 then
    local hours = math.floor(diff / 3600)
    if hours == 0 then
      local mins = math.floor(diff / 60)
      return mins .. 'm'
    end
    return hours .. 'h'
  elseif days < 7 then
    return days .. 'd'
  elseif days < 30 then
    local weeks = math.floor(days / 7)
    return weeks .. 'w'
  elseif days < 365 then
    local months = math.floor(days / 30)
    return months .. 'mo'
  else
    local years = math.floor(days / 365)
    return years .. 'y'
  end
end

function Linemode:daysfrom()
  -- Extract date from filename (handles both YYYY-MM-DD and YYYY-MM-DD[Day] formats)
  local filename = self._file.name
  local date_pattern = "^(%d%d%d%d)%-(%d%d)%-(%d%d)"
  local year, month, day = filename:match(date_pattern)
  
  -- If not a date folder, return empty
  if not year or not month or not day then
    return ''
  end
  
  -- Get today's date at midnight
  local today = os.date("*t")
  today.hour = 0
  today.min = 0
  today.sec = 0
  local today_time = os.time(today)
  
  -- Create time for the folder date at midnight
  local folder_time = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = 0,
    min = 0,
    sec = 0
  })
  
  -- Calculate difference in days
  local diff_seconds = folder_time - today_time
  local diff_days = math.floor(diff_seconds / 86400)
  
  -- Always show "Today" regardless of tag
  if diff_days == 0 then
    return 'Today'
  end
  
  -- Check if this directory has a Red tag for other dates
  -- Access the mactag-unified module's tags if available
  local mactag = package.loaded["mactag-unified"]
  if mactag and mactag.tags then
    local path = tostring(self._file.url)
    local tags = mactag.tags[path]
    
    -- Only show day count for Red-tagged directories (but not today)
    if not tags or not tags[1] or tags[1] ~= "Red" then
      return ''
    end
  end
  
  -- Format the output for Red-tagged directories
  if diff_days == 0 then
    return 'Today'
  elseif diff_days == 1 then
    return 'Tomorrow'
  elseif diff_days == -1 then
    return 'Yesterday'
  elseif diff_days > 0 then
    return '+' .. diff_days .. 'd'
  else
    return diff_days .. 'd'
  end
end

-- require('simple-tag'):setup {
--   -- UI display mode (icon, text, hidden)
--   ui_mode = 'icon', -- (Optional)
--
--   -- Disable tag key hints (popup in bottom right corner)
--   hints_disabled = false, -- (Optional)
--
--   -- linemode order: adjusts icon/text position. Fo example, if you want icon to be on the mose left of linemode then set linemode_order larger than 1000.
--   -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-plugin/preset/components/linemode.lua#L4-L5
--   linemode_order = 500, -- (Optional)
--
--   -- You can backup/restore this folder. But don't use backed up folder in the different OS.
--   -- save_path =  -- full path to save tags folder (Optional)
--   --       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/tags"
--   --       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\tags"
--
--   -- Set tag colors
--   colors = { -- (Optional)
--     -- Set this same value with `theme.toml` > [manager] > hovered > reversed
--     -- Default theme use "reversed = true".
--     -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-config/preset/theme-dark.toml#L25
--     reversed = true, -- (Optional)
--
--     -- More colors: https://yazi-rs.github.io/docs/configuration/theme#types.color
--     -- format: [tag key] = "color"
--     ['*'] = '#bf68d9', -- (Optional)
--     ['$'] = 'green',
--     ['!'] = '#cc9057',
--     ['1'] = 'cyan',
--     ['p'] = 'red',
--   },
--
--   -- Set tag icons. Only show when ui_mode = "icon".
--   -- Any text or nerdfont icons should work
--   -- Default icon from mactag.yazi: ●; , , 󱈤
--   -- More icon from nerd fonts: https://www.nerdfonts.com/cheat-sheet
--   icons = { -- (Optional)
--     -- default icon
--     default = '󰚋',
--
--     -- format: [tag key] = "tag icon"
--     ['*'] = '*',
--     ['$'] = '',
--     ['!'] = '',
--     ['p'] = '',
--   },
-- }

require('bunny'):setup {
  hops = {
    { key = 'h', path = '~', desc = 'Home' },
    { key = 'd', path = '~/Downloads', desc = 'Downloads' },
    { key = 'a', path = '~/dotfiles', desc = 'Config files' },
    { key = 'c', path = '~/Documents/diary/', desc = 'Commitments' },
    { key = 't', path = '~/Documents/technion', desc = 'Technion' },
    { key = 'y', path = '~/dotfiles/.config/yazi', desc = 'Yazi config' },
    { key = 'v', path = '~/vaults-icloud-obsidian/personal-vault', desc = 'Personal vault' },
    { key = 'p', path = '~/Documents/prompts', desc = 'Prompts' },
    -- Add other frequent directories you use
  },
  desc_strategy = 'path',
  notify = false,
  fuzzy_cmd = "fzf --preview='echo {} | cut -f2 | xargs -I@ eza --tree --level=2 --color=always --icons --git @'",
}

require('jump-back'):setup()

require('eza-preview'):setup {
  -- Set initial state to hide hidden files
  all = false,
}

-- Enable zoxide integration to automatically add visited directories
require('zoxide'):setup {
  update_db = true,
}

-- Sync yanked files across all Yazi instances
require('session'):setup {
  sync_yanked = true,
}



-- Unified macOS tag plugin
require("mactag-unified"):setup()

-- Tag filter plugin (works with unified state)
require("mactag-filter"):setup()

-- Test icon plugin (kept for reference/debugging)
-- require("test-icon"):setup()

