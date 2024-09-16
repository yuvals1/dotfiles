local repl = require 'plugins.iron.repl'
local iron = require 'iron.core'
local execution_tracker = require 'plugins.iron.execution_tracker'

local M = {}

-- Helper function to ensure there's a line to move to
local function ensure_next_line()
  local last_line = vim.fn.line '$'
  local last_line_content = vim.fn.getline(last_line)

  if vim.fn.line '.' == last_line or last_line_content:match '^%s*$' then
    vim.fn.append(last_line, '')
    return true
  end
  return false
end

M.execute_line = function()
  local current_line = vim.fn.line '.'
  local current_line_content = vim.api.nvim_get_current_line()
  repl.send_to_repl(current_line_content, current_line, current_line, 'line')
end

M.execute_line_and_move = function()
  M.execute_line()
  local created_new_line = ensure_next_line()
  vim.cmd(created_new_line and 'normal! j$' or 'normal! j')
end

M.execute_file = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, '\n')
  repl.send_to_repl(code, 1, #lines, 'file')
end

-- Helper function to execute Python extractor
local function execute_python_extractor(line_number, command)
  local python_path = vim.g.python3_host_prog
  local script_path = vim.fn.expand '~/.config/nvim/lua/plugins/iron/code_block_extractor.py'

  if vim.fn.filereadable(script_path) == 0 then
    vim.api.nvim_echo({ { string.format('Error: Script not found at %s', script_path), 'ErrorMsg' } }, false, {})
    return
  end

  local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  local tmp_file = vim.fn.tempname()
  local tmp_fd = io.open(tmp_file, 'w')
  tmp_fd:write(buffer_content)
  tmp_fd:close()

  local cmd = string.format('%s %s %d %s < %s', python_path, script_path, line_number, command, tmp_file)
  local output = vim.fn.system(cmd)

  os.remove(tmp_file)
  return output
end

-- Helper function to check if a block is executed
local function is_block_executed(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local signs = vim.fn.sign_getplaced(bufnr, { group = 'IronExecutionGroup' })[1].signs
  for _, sign in ipairs(signs) do
    if sign.lnum >= start_line and sign.lnum <= end_line then
      return true
    end
  end
  return false
end

-- Helper function to get all blocks up to the cursor
local function get_blocks_up_to_cursor(cursor_line)
  local blocks = {}
  local line = 1
  while line <= cursor_line do
    local range = execute_python_extractor(line, 'range')
    local start, end_line = range:match '(%d+),(%d+)'
    start, end_line = tonumber(start), tonumber(end_line)
    table.insert(blocks, { start = start, end_line = end_line, code = execute_python_extractor(line, 'block') })
    line = end_line + 1
  end
  return blocks
end

M.execute_until_cursor = function()
  if vim.bo.filetype ~= 'python' then
    print 'This function is only for Python files.'
    return
  end

  local cursor_line = vim.fn.line '.'
  local blocks = get_blocks_up_to_cursor(cursor_line)

  local blocks_to_execute = {}
  local current_block_index = 0

  for i, block in ipairs(blocks) do
    if cursor_line >= block.start and cursor_line <= block.end_line then
      current_block_index = i
      break
    end
  end

  if current_block_index == 0 then
    print 'Cursor is not in a valid code block.'
    return
  end

  if is_block_executed(blocks[current_block_index].start, blocks[current_block_index].end_line) then
    print 'The current block has already been executed.'
    return
  end

  for i = 1, current_block_index do
    if not is_block_executed(blocks[i].start, blocks[i].end_line) then
      table.insert(blocks_to_execute, blocks[i])
    end
  end

  for _, block in ipairs(blocks_to_execute) do
    repl.send_to_repl(block.code, block.start, block.end_line, 'smart')
  end

  -- Move to the next line after the last executed block
  local last_executed_block = blocks_to_execute[#blocks_to_execute]
  local created_new_line = ensure_next_line()
  if created_new_line then
    vim.api.nvim_win_set_cursor(0, { last_executed_block.end_line + 1, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { math.min(last_executed_block.end_line + 1, vim.fn.line '$'), 0 })
  end
end

M.smart_execute = function()
  if vim.bo.filetype ~= 'python' then
    print 'This function is only for Python files.'
    return
  end

  local current_line = vim.fn.line '.'
  local code_block = execute_python_extractor(current_line, 'block')
  local range = execute_python_extractor(current_line, 'range')
  local start_line, end_line = range:match '(%d+),(%d+)'

  repl.send_to_repl(code_block, tonumber(start_line), tonumber(end_line), 'smart')
end

M.smart_execute_and_move = function()
  M.smart_execute()
  local range = execute_python_extractor(vim.fn.line '.', 'range')
  local _, end_line = range:match '(%d+),(%d+)'
  end_line = tonumber(end_line)

  local created_new_line = ensure_next_line()
  if created_new_line then
    vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { math.min(end_line + 1, vim.fn.line '$'), 0 })
  end
end

return M
