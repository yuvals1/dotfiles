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
  local encoded = base64_encode(content)
  local osc52_seq = string.format('\x1b]52;c;%s\x07', encoded)
  local stderr = io.stderr
  stderr:write(osc52_seq)
  stderr:flush()
  return true
end

-- Smart clipboard function that handles both local and remote copying
local function smart_clipboard(content)
  if is_ssh_session() then
    local success = osc52_copy(content)
    if not success then
      info 'OSC52 copy failed, falling back to regular clipboard'
      ya.clipboard(content)
    end
  else
    ya.clipboard(content)
  end
end

local function info(content)
  return ya.notify {
    title = 'Yank Content',
    content = content,
    timeout = 5,
  }
end

local hovered_url = ya.sync(function()
  local h = cx.active.current.hovered
  return h and h.url
end)

return {
  entry = function()
    local file_url = hovered_url()
    if not file_url then
      return info 'No file hovered'
    end
    local output, err = Command('cat'):arg(tostring(file_url)):output()
    if not output then
      return info('Failed to read file, error: ' .. err)
    end
    smart_clipboard(output.stdout)
    info 'File content copied to clipboard'
  end,
}
