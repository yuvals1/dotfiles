require('git'):setup {}
-- require('my_linemode'):setup()
require('full-border'):setup()
-- require('star_linemode'):setup()

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

require('yamb'):setup {
  -- Optional, the path ending with path seperator represents folder.
  bookmarks = bookmarks,
  -- Optional, recieve notification everytime you jump.
  jump_notify = true,
  -- Optional, the cli of fzf.
  cli = 'fzf',
  -- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
  keys = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
  -- Optional, the path of bookmarks
  path = (ya.target_family() == 'windows' and os.getenv 'APPDATA' .. '\\yazi\\config\\bookmark') or (os.getenv 'HOME' .. '/.config/yazi/bookmark'),
}

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
