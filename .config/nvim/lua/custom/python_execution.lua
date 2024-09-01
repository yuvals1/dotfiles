-- Set the Python interpreter path to use the virtualenv
vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim311/bin/python3'

-- Function to execute Python code extractor
local function execute_python_extractor(line_number, command)
  local python_path = vim.g.python3_host_prog
  local script_path = vim.fn.expand '~/.config/nvim/lua/custom/code_block_extractor.py'

  -- Check if the Python script exists
  if vim.fn.filereadable(script_path) == 0 then
    vim.api.nvim_echo({ { string.format('Error: Script not found at %s', script_path), 'ErrorMsg' } }, false, {})
    return
  end

  -- Get the current buffer content
  local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

  -- Create a temporary file to store the buffer content
  local tmp_file = vim.fn.tempname()
  local tmp_fd = io.open(tmp_file, 'w')
  tmp_fd:write(buffer_content)
  tmp_fd:close()

  -- Execute the Python script
  local cmd = string.format('%s %s %d %s < %s', python_path, script_path, line_number, command, tmp_file)
  local output = vim.fn.system(cmd)

  -- Remove the temporary file
  os.remove(tmp_file)

  return output
end

-- Function to display output in a floating window
local function display_in_float(output)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(output, '\n'))

  local width = 60
  local height = 10
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
  })
end

-- Function to extract code block
local function extract_code_block()
  local output = execute_python_extractor(vim.fn.line '.', 'block')
  display_in_float(output)
end

-- Function to get line range
local function get_line_range()
  local output = execute_python_extractor(vim.fn.line '.', 'range')
  vim.api.nvim_echo({ { 'Block range: ' .. output, 'Normal' } }, false, {})
end

-- Commands to call the functions
vim.api.nvim_create_user_command('ExtractCodeBlock', extract_code_block, {})
vim.api.nvim_create_user_command('GetBlockRange', get_line_range, {})

-- Keybindings
vim.api.nvim_set_keymap('n', '<leader>eb', ':ExtractCodeBlock<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>er', ':GetBlockRange<CR>', { noremap = true, silent = true })
