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
    result=$(for dir in ]] .. folders .. [[; do
      dir="${dir%/}"
      if [ -d "$dir" ]; then
        (cd "$dir" 2>/dev/null && fd --type f \
          --hidden \
          --no-ignore \
          --color=always \
          --exclude .git \
          --exclude .mypy_cache \
          --exclude __pycache__ \
          --exclude node_modules \
          --exclude venv \
          --exclude dist \
          --exclude build | \
          awk -v dir="$dir" '{printf "%s\t\033[0m%s\n", dir"/"$0, $0}') 
      fi
    done | awk -F'\t' '
      {
        full=$1
        rel=$2
        gsub(/^\.\//, "", rel)
        
        split(full, parts, "/")
        last_idx = length(parts)
        
        if (rel ~ "/") {
          base_dir = parts[last_idx-2]
        } else {
          base_dir = parts[last_idx-1]
        }
        
        if (!(full in seen) || length(rel) < length(seen[full])) {
          seen[full] = rel
          seen_base[full] = base_dir
          paths[full] = base_dir "/" rel
        }
      }
      END {
        for (p in paths) {
          print p "\t" paths[p]
        }
      }
    ')
    
    if [ -n "$result" ]; then
      echo "$result" | fzf \
        --ansi \
        --delimiter='\t' \
        --with-nth=2 \
        --preview "bat --style=numbers --color=always {1}" \
        --header='Search in bookmarked folders'
    else
      echo "No files found" >&2
      exit 1
    fi
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
    ya.manager_emit(target:find '[/\\]$' and 'cd' or 'reveal', { target })
  end
end

return { entry = entry }
