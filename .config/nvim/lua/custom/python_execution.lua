-- Set the Python interpreter path to use the virtualenv
vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim311/bin/python3'

-- Function to execute Python code
local function execute_python_extractor(line_number)
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
  local command = string.format('%s %s %d < %s', python_path, script_path, line_number, tmp_file)
  local output = vim.fn.system(command)

  -- Remove the temporary file
  os.remove(tmp_file)

  -- Display the output in a floating window
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

-- Command to call the function
vim.api.nvim_create_user_command('ExtractCodeBlock', function(opts)
  execute_python_extractor(vim.fn.line '.')
end, {})
