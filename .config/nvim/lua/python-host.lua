local M = {}

-- Function to run shell commands
local function run_command(cmd)
  local handle = io.popen(cmd)
  local result = handle:read '*a'
  handle:close()
  return result
end

-- Function to check if a directory exists
local function dir_exists(dir)
  local ok, _, code = os.rename(dir, dir)
  return ok, code
end

-- Setup function
function M.setup()
  local home = os.getenv 'HOME'
  local venv_path = home .. '/venvs/neovim312'
  local python_path = venv_path .. '/bin/python3'

  -- Create virtual environment if it doesn't exist
  if not dir_exists(venv_path) then
    print 'Creating virtual environment...'
    run_command('uv venv ' .. venv_path)
    -- Activate virtual environment and install/upgrade pynvim
    print 'Installing/upgrading pynvim...'
    run_command('source ' .. venv_path .. '/bin/activate && uv pip install pynvim && deactivate')
  end

  -- Set python3_host_prog
  vim.g.python3_host_prog = python_path
end

-- Run setup on module load
M.setup()

return M
