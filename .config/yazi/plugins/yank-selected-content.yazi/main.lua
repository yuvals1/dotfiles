-- TODO: extract the smart_clipboard function to a separate module
-- Configuration
local CONFIG = {
  log_to_file = false, -- Set this to false to disable logging to file
}

local function get_log_file_path()
  local home = os.getenv 'HOME'
  return home .. '/.config/yazi/yank-selected-content.log'
end

local function log_to_file(message)
  if not CONFIG.log_to_file then
    return -- Exit the function if logging is disabled
  end
  local log_file = io.open(get_log_file_path(), 'a')
  if log_file then
    local timestamp = os.date '%Y-%m-%d %H:%M:%S'
    log_file:write(string.format('[%s] %s\n', timestamp, message))
    log_file:close()
  end
end

local function info(content)
  log_to_file(content)
  return ya.notify {
    title = 'Yank Content',
    content = content,
    timeout = 5,
  }
end

-- Base64 encoding table
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Function to encode string to base64
local function base64_encode(data)
  local bytes = {}
  local result = ''

  for i = 1, #data do
    bytes[#bytes + 1] = string.byte(data, i)
  end

  local padding = #data % 3
  if padding > 0 then
    for i = 1, 3 - padding do
      bytes[#bytes + 1] = 0
    end
  end

  for i = 1, #bytes, 3 do
    local n = (bytes[i] << 16) + (bytes[i + 1] << 8) + bytes[i + 2]
    local char1 = b64chars:sub(((n >> 18) & 0x3F) + 1, ((n >> 18) & 0x3F) + 1)
    local char2 = b64chars:sub(((n >> 12) & 0x3F) + 1, ((n >> 12) & 0x3F) + 1)
    local char3 = b64chars:sub(((n >> 6) & 0x3F) + 1, ((n >> 6) & 0x3F) + 1)
    local char4 = b64chars:sub((n & 0x3F) + 1, (n & 0x3F) + 1)
    result = result .. char1 .. char2 .. char3 .. char4
  end

  if padding == 1 then
    result = result:sub(1, -2) .. '='
  elseif padding == 2 then
    result = result:sub(1, -3) .. '=='
  end

  return result
end

-- Function to check if we're in an SSH session
local function is_ssh_session()
  return os.getenv 'SSH_CLIENT' ~= nil or os.getenv 'SSH_TTY' ~= nil
end

-- Function to copy using OSC52
local function osc52_copy(content)
  -- Base64 encode the content using our pure Lua implementation
  local encoded = base64_encode(content)

  -- Create OSC52 sequence
  local osc52_seq = string.format('\x1b]52;c;%s\x07', encoded)

  -- Write to stderr
  local stderr = io.stderr
  stderr:write(osc52_seq)
  stderr:flush()

  return true
end

-- Modified clipboard function that handles both local and remote copying
local function smart_clipboard(content)
  if is_ssh_session() then
    local success = osc52_copy(content)
    if not success then
      info 'OSC52 copy failed, falling back to regular clipboard'
      -- Fallback to regular clipboard as backup
      ya.clipboard(content)
    end
  else
    -- Use regular clipboard for local sessions
    ya.clipboard(content)
  end
end

local function safe_access(func, default)
  local success, result = pcall(func)
  if success then
    return result
  else
    return 'Error: ' .. tostring(result)
  end
end

local get_selected_files = ya.sync(function()
  local selected = {}
  for _, u in pairs(cx.active.selected) do
    table.insert(selected, tostring(u))
  end
  return selected
end)

local get_hovered_file = ya.sync(function()
  local h = cx.active.current.hovered
  return h and tostring(h.url)
end)

local function get_file_content(file_path)
  local output, err = Command('cat'):arg(file_path):output()
  if not output then
    return nil, 'Failed to read file: ' .. file_path .. ', error: ' .. err
  end
  return output.stdout, nil
end

local function get_language(file)
  local ext = file:match '%.([^%.]+)$'
  if ext then
    ext = ext:lower()
    local extensions = {
      py = 'python',
      js = 'javascript',
      html = 'html',
      css = 'css',
      lua = 'lua',
      md = 'markdown',
      txt = 'text',
      -- Add more as needed
    }
    return extensions[ext] or 'text'
  end
  return 'text'
end

local function get_common_prefix(paths)
  if #paths == 0 then
    return ''
  end
  local shortest = paths[1]
  for i = 2, #paths do
    if #paths[i] < #shortest then
      shortest = paths[i]
    end
  end
  local common_prefix = ''
  for i = 1, #shortest do
    local char = shortest:sub(i, i)
    for j = 1, #paths do
      if paths[j]:sub(i, i) ~= char then
        return common_prefix
      end
    end
    common_prefix = common_prefix .. char
  end
  return common_prefix:match '(.*/)' or ''
end

local function get_relative_path(file_path, common_prefix)
  return file_path:sub(#common_prefix + 1)
end

return {
  entry = function()
    local selected_files = safe_access(get_selected_files, {})

    if #selected_files == 0 then
      -- No files selected, use hovered file
      local hovered_file = safe_access(get_hovered_file)
      if not hovered_file then
        return info 'No file selected or hovered'
      end
      selected_files = { hovered_file }
    end

    local common_prefix = get_common_prefix(selected_files)
    local content = '# base path: ' .. common_prefix .. '\n\n'
    local error_messages = {}
    local file_count = 0
    local total_lines = 0

    for _, file_path in ipairs(selected_files) do
      local file_content, err = get_file_content(file_path)
      if file_content then
        local relative_path = get_relative_path(file_path, common_prefix)
        local language = get_language(file_path)
        content = content .. '## ' .. relative_path .. '\n'
        content = content .. '````' .. language .. '\n'
        content = content .. file_content
        content = content .. '````\n\n'
        file_count = file_count + 1
        total_lines = total_lines + select(2, file_content:gsub('\n', '\n'))
      else
        table.insert(error_messages, err)
      end
    end

    if content ~= '' then
      smart_clipboard(content) -- Using our new smart clipboard function
      local success_message
      if file_count == 1 then
        success_message = string.format('Copied content of 1 file (%d lines) to clipboard', total_lines)
      else
        success_message = string.format('Copied content of %d files (%d lines) to clipboard', file_count, total_lines)
      end
      info(success_message)
    end

    if #error_messages > 0 then
      local error_content = 'Errors:\n' .. table.concat(error_messages, '\n')
      info(error_content)
    end
  end,
}
