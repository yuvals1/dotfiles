-- Base64 encoding table
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Function to encode string to base64
local function base64_encode(data)
  local bytes = {}
  local result = ""
  
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
    result = result:sub(1, -2) .. "="
  elseif padding == 2 then
    result = result:sub(1, -3) .. "=="
  end

  return result
end

-- Function to check if we're in an SSH session
local function is_ssh_session()
  return os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil
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
      info("OSC52 copy failed, falling back to regular clipboard")
      ya.clipboard(content)
    end
  else
    ya.clipboard(content)
  end
end

local function info(content)
	return ya.notify({
		title = "Yank Directory Content",
		content = content,
		timeout = 5,
	})
end

local hovered_url = ya.sync(function()
	local h = cx.active.current.hovered
	return h and h.url
end)

local function get_language(file)
	local ext = file:match("%.([^%.]+)$")
	if ext then
		ext = ext:lower()
		local extensions = {
			py = "python",
			ts = "typescript",
			tsx = "typescript",
			js = "javascript",
			jsx = "javascript",
			html = "html",
			css = "css",
			lua = "lua",
			md = "markdown",
			txt = "text",
			json = "json",
			yaml = "yaml",
			yml = "yaml",
			toml = "toml",
			sh = "bash",
			bash = "bash",
			zsh = "bash",
			sql = "sql",
			xml = "xml",
			rs = "rst",
			go = "go",
			-- Add more as needed
		}
		return extensions[ext]
	end
	return nil
end

local function split_path(path)
	local parts = {}
	for part in path:gmatch("[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

local function format_path(path, base_path)
	return path:sub(#base_path + 2) -- +2 to remove leading '/'
end

-- Improved path comparison function
local function compare_paths(a, b)
	local a_parts = split_path(a)
	local b_parts = split_path(b)
	for i = 1, math.min(#a_parts, #b_parts) do
		if a_parts[i] ~= b_parts[i] then
			if a_parts[i]:match("%.yazi$") and not b_parts[i]:match("%.yazi$") then
				return false
			elseif b_parts[i]:match("%.yazi$") and not a_parts[i]:match("%.yazi$") then
				return true
			else
				return a_parts[i] < b_parts[i]
			end
		end
	end
	return #a_parts < #b_parts
end

-- Function to generate ASCII tree
local function generate_tree(dir_url)
	local output, err = Command("tree")
		:arg("-L")
		:arg("3") -- Limit depth to 3 levels, adjust as needed
		:arg("--charset=ascii") -- Use ASCII characters for compatibility
		:arg("-I")
		:arg(".venv|__pycache__|.mypy_cache|.git|node_modules") -- Ignore specified directories
		:arg(tostring(dir_url))
		:output()

	if not output then
		return "Failed to generate tree, error: " .. err
	end

	return output.stdout
end

return {
	entry = function()
		local dir_url = hovered_url()
		if not dir_url then
			return info("No directory hovered")
		end

		local is_dir = ya.sync(function()
			return cx.active.current.hovered.cha.is_dir
		end)

		if not is_dir then
			return info("Hovered item is not a directory")
		end

		-- Generate ASCII tree
		local tree_content = generate_tree(dir_url)

		local output, err = Command("find")
			:arg(tostring(dir_url))
			:arg("-not")
			:arg("-path")
			:arg("*/.venv/*") -- Exclude .venv directories
			:arg("-not")
			:arg("-path")
			:arg("*/__pycache__/*") -- Exclude __pycache__ directories
			:arg("-not")
			:arg("-path")
			:arg("*/.mypy_cache/*") -- Exclude .mypy_cache directories
			:arg("-not")
			:arg("-path")
			:arg("*/.git/*") -- Exclude .git directories
			:arg("-not")
			:arg("-path")
			:arg("*/node_modules/*") -- Exclude node_modules directories
			:output()
		if not output then
			return info("Failed to list directory contents, error: " .. err)
		end

		local paths = {}
		for path in output.stdout:gmatch("[^\r\n]+") do
			table.insert(paths, path)
		end
		table.sort(paths, compare_paths)

		local content = tree_content .. "\n\n" -- Add tree content at the top
		local prev_parts = {}
		local total_lines = 0
		local file_count = 0
		local skipped_count = 0

		for _, path in ipairs(paths) do
			local formatted_path = format_path(path, tostring(dir_url))
			local parts = split_path(formatted_path)
			local is_file = ya.sync(function()
				return not fs.stat(path).is_dir
			end)

			-- Skip specified directories
			if formatted_path:match("^%.venv") or formatted_path:match("/%.venv") or
			   formatted_path:match("^__pycache__") or formatted_path:match("/__pycache__") or
			   formatted_path:match("^%.mypy_cache") or formatted_path:match("/%.mypy_cache") or
			   formatted_path:match("^%.git") or formatted_path:match("/%.git") or
			   formatted_path:match("^node_modules") or formatted_path:match("/node_modules") then
				goto continue
			end

			-- Output headers for new directories
			for i = 1, #parts do
				if i > #prev_parts or parts[i] ~= prev_parts[i] then
					content = content .. string.rep("#", i) .. " " .. table.concat(parts, "/", 1, i) .. "\n"
					if i == #parts and not is_file then
						content = content .. "````\n````\n" -- Add empty code block for directories
					end
				end
			end

			if is_file then
				local language = get_language(path)
				if language then
					local file_content, file_err = Command("cat"):arg(path):output()
					if file_content then
						content = content .. "````" .. language .. "\n"
						content = content .. file_content.stdout
						content = content .. "````\n\n"

						local file_lines = select(2, file_content.stdout:gsub("\n", "\n"))
						total_lines = total_lines + file_lines
						file_count = file_count + 1
					else
						content = content .. "Error reading file: " .. file_err .. "\n\n"
					end
				else
					skipped_count = skipped_count + 1
				end
			end

			prev_parts = parts
			::continue::
		end

		smart_clipboard(content) -- Using smart clipboard instead of ya.clipboard
		info(
			string.format(
				"Copied tree and content of %d files (%d lines) to clipboard. Skipped %d unsupported files.",
				file_count,
				total_lines,
				skipped_count
			)
		)
	end,
}
