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
    -- Always sort ~/tasks alphabetically
    { location = ".*/tasks$", 
      sort = { "alphabetical", reverse = false, dir_first = true },
      linemode = "none"
    },
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

function Linemode:lines()
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


-- Original mactag setup (commented out, keeping for reference)
-- require("mactag"):setup {
-- 	-- Keys used to add or remove tags
-- 	keys = {
-- 		r = "Red",
-- 		o = "Orange",
-- 		y = "Yellow",
-- 		g = "Green",
-- 		b = "Blue",
-- 		p = "Purple",
-- 	},
-- 	-- Colors used to display tags
-- 	colors = {
-- 		Red    = "#ee7b70",
-- 		Orange = "#f5bd5c",
-- 		Yellow = "#fbe764",
-- 		Green  = "#91fc87",
-- 		Blue   = "#5fa3f8",
-- 		Purple = "#cb88f8",
-- 	},
-- }

-- Simplified red-only tag plugin
require("mactag-red"):setup {
	color = "#ee7b70"  -- Red color
}
