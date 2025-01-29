local function read_frecency()
  local home = os.getenv 'HOME'
  local frecency_file = home .. '/.yazi_frecency.txt'
  local scores = {}

  local file = io.open(frecency_file, 'r')
  if file then
    for line in file:lines() do
      local filepath, count, last_access = line:match '([^\t]+)\t(%d+)\t(%d+)'
      if filepath and count and last_access then
        scores[filepath] = {
          count = tonumber(count),
          last_access = tonumber(last_access),
        }
      end
    end
    file:close()
  end
  return scores
end

local function update_frecency(filepath)
  local home = os.getenv 'HOME'
  local frecency_file = home .. '/.yazi_frecency.txt'
  local scores = read_frecency()

  -- Update or add new entry
  local current_time = os.time()
  if scores[filepath] then
    scores[filepath].count = scores[filepath].count + 1
    scores[filepath].last_access = current_time
  else
    scores[filepath] = { count = 1, last_access = current_time }
  end

  -- Write back to file
  local file = io.open(frecency_file, 'w')
  if file then
    for path, data in pairs(scores) do
      file:write(string.format('%s\t%d\t%d\n', path, data.count, data.last_access))
    end
    file:close()
  end
end

local function read_bookmarks()
  local home = os.getenv 'HOME'
  local bookmark_file = home .. '/.config/yazi/bookmark'
  local paths = {}
  local file = io.open(bookmark_file, 'r')
  if not file then
    ya.notify { title = 'FZF', content = 'Could not open bookmark file', level = 'error' }
    return {}
  end
  for line in file:lines() do
    if not line:match '^%s*#' and line:match '%S' then
      local parts = {}
      for part in line:gmatch '[^\t]+' do
        table.insert(parts, part)
      end
      if parts[2] then
        local path = parts[2]:gsub('/$', '')
        paths[#paths + 1] = path
      end
    end
  end
  file:close()
  return table.concat(paths, ' ')
end

local state = ya.sync(function()
  return cx.active.current.cwd
end)

local function fail(s, ...)
  ya.notify { title = 'Fzf', content = string.format(s, ...), timeout = 5, level = 'error' }
end

local function entry()
  local _permit = ya.hide()
  local cwd = tostring(state())
  local folders = read_bookmarks()
  if folders == '' then
    return fail 'No bookmarks found'
  end

  local find_cmd = [[
frecency_file="${HOME}/.yazi_frecency.txt"
separator="━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

{
  # First output frecency files
  if [ -f "$frecency_file" ]; then
    cut -f1 "$frecency_file" | while read -r tracked_file; do
      for dir in ]] .. folders .. [[; do
        dir="${dir%/}"
        if [ -d "$dir" ]; then
          bookmark_name=$(basename "$dir")
          if [ -f "$tracked_file" ] && echo "$tracked_file" | grep -q "^$dir/"; then
            rel_path=${tracked_file#$dir/}
            printf "%s\t\033[0m%s/%s\n" "$tracked_file" "$bookmark_name" "$rel_path"
          fi
        fi
      done
    done
  fi

  # Output separator
  printf "%s\t%s\n" "$separator" "$separator"

  # Then output regular results
  for dir in ]] .. folders .. [[; do
    dir="${dir%/}"
    if [ -d "$dir" ]; then
      bookmark_name=$(basename "$dir")
      cd "$dir" 2>/dev/null && fd --type f \
        --hidden \
        --no-ignore \
        --color=always \
        --exclude .git \
        --exclude .mypy_cache \
        --exclude __pycache__ \
        --exclude node_modules \
        --exclude venv \
        --exclude dist \
        --exclude build \
        --strip-cwd-prefix | while read -r file; do
          full_path="$dir/$file"
          printf "%s\t\033[0m%s/%s\n" "$full_path" "$bookmark_name" "$file"
        done
    fi
  done
} | awk -F'\t' '
  {
    full=$1
    rel=$2
    
    if (full == "━━━━━━━━━━━━━━━━━━━━━━━━━━━━") {
      print "\033[0;34m" full "\033[0m"
      separator_seen = 1
    }
    else {
      # For regular entries
      cleaned_full = full
      # Remove ANSI color codes if any
      gsub(/\033\[[0-9;]*m/, "", cleaned_full)
      
      if (!seen[cleaned_full]++) {
        if (separator_seen) {
          # Only print if we have not seen this path in the frecency section
          if (!(cleaned_full in frecency_seen)) {
            print full "\t" rel
          }
        } else {
          # Mark this as seen in frecency section
          frecency_seen[cleaned_full] = 1
          print full "\t" rel
        }
      }
    }
  }
' | fzf \
    --ansi \
    --delimiter='\t' \
    --with-nth=2 \
    --preview "bat --style=numbers --color=always {1}" \
    --header='Search in bookmarked folders'
]]

  local child, err = Command('sh'):args({ '-c', find_cmd }):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
  if not child then
    return fail('Failed to start command, error: ' .. err)
  end
  local output, err = child:wait_with_output()
  if not output then
    return fail('Cannot read output, error: ' .. err)
  elseif not output.status.success and output.status.code ~= 130 then
    return fail('Command exited with error code %s', output.status.code)
  end
  local target = output.stdout:gsub('\n$', ''):match '^([^\t]+)'
  if target and target ~= '' then
    -- Update frecency data when a file is selected
    update_frecency(target)
    ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
  end
end

return { entry = entry }
