local iron = require 'iron.core'
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

M.custom_repl_open_cmd = function(bufnr)
  local width = math.floor(vim.o.columns * 0.4)
  vim.cmd('botright vertical ' .. width .. 'split')
  vim.api.nvim_win_set_buf(0, bufnr)
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
  return win
end

M.execute_cell = function()
  local start_line = vim.fn.search('^# %%', 'bnW')
  local end_line = vim.fn.search('^# %%', 'nW') - 1
  if end_line == -1 then
    end_line = vim.fn.line '$'
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  lines = vim.tbl_filter(function(line)
    return not line:match '^# %%'
  end, lines)

  local code = table.concat(lines, '\n')
  iron.send(vim.bo.filetype, code)
end

M.execute_cell_and_move = function()
  M.execute_cell()
  vim.cmd [[
    if search('^# %%', 'nW') == 0
      " We're in the last cell, create a new one
      normal! G
      call append(line('.'), ['', '# %%', ''])
      normal! 3j
    else
      " Move to the next cell
      call search('^# %%', 'W')
      normal! j
    endif
  ]]
end

M.execute_line_and_move = function()
  local current_line = vim.api.nvim_get_current_line()
  iron.send(vim.bo.filetype, current_line)

  local last_line = vim.fn.line '$'
  local current_line_num = vim.fn.line '.'

  if current_line_num == last_line then
    -- If it's the last line, create a new line and move to it
    vim.cmd 'normal! o'
  else
    -- Otherwise, just move to the next line
    vim.cmd 'normal! j'
  end
end

M.execute_line = function()
  local current_line = vim.api.nvim_get_current_line()
  iron.send(vim.bo.filetype, current_line)
end

M.create_cell_below = function()
  local current_line = vim.fn.line '.'
  vim.api.nvim_buf_set_lines(0, current_line, current_line, false, { '', '# %%', '' })
  vim.api.nvim_win_set_cursor(0, { current_line + 3, 0 })
end

M.remove_current_cell = function()
  local current_line = vim.fn.line '.'
  local start_line = vim.fn.search('^# %%', 'bnW')
  local end_line = vim.fn.search('^# %%', 'nW') - 1

  if start_line == 0 then
    start_line = 1
  end

  if end_line == -1 then
    end_line = vim.fn.line '$'
  end

  -- Delete the cell
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})

  -- Move cursor to the start of the next cell or the end of the file
  local next_cell = vim.fn.search('^# %%', 'nW')
  if next_cell == 0 then
    vim.api.nvim_win_set_cursor(0, { vim.fn.line '$', 0 })
  else
    vim.api.nvim_win_set_cursor(0, { next_cell, 0 })
  end
end

local function is_executable_node(node_type)
  return node_type == 'function_definition'
    or node_type == 'class_definition'
    or node_type == 'if_statement'
    or node_type == 'for_statement'
    or node_type == 'while_statement'
    or node_type == 'try_statement'
    or node_type == 'with_statement'
    or node_type == 'decorated_definition'
    or node_type == 'lambda'
    or node_type == 'list_comprehension'
    or node_type == 'set_comprehension'
    or node_type == 'dictionary_comprehension'
    or node_type == 'generator_expression'
    or node_type == 'string'
    or node_type == 'expression_statement'
end

local function get_parent_class(node)
  while node do
    if node:type() == 'class_definition' then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function get_parent_function(node)
  while node do
    if node:type() == 'function_definition' then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function get_parent_decorator(node)
  while node do
    if node:type() == 'decorated_definition' then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function is_nested_function(node)
  local parent = node:parent()
  if parent and parent:type() == 'function_definition' then
    local grandparent = parent:parent()
    return grandparent and grandparent:type() == 'function_definition'
  end
  return false
end

M.smart_execute = function()
  if vim.bo.filetype ~= 'python' then
    print 'This function is only for Python files.'
    return
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then
    print 'No executable construct found at cursor.'
    return
  end

  -- Check if we're on an empty line or a line with only whitespace
  local line = vim.api.nvim_get_current_line()
  if line:match '^%s*$' then
    print 'Cursor is on an empty line. No code to execute.'
    return
  end

  -- The rest of the function remains the same...
  local class_node = get_parent_class(node)
  if class_node then
    node = class_node
  else
    if is_nested_function(node) then
      node = node:parent():parent()
    else
      local decorator_node = get_parent_decorator(node)
      if decorator_node then
        node = decorator_node
      else
        local function_node = get_parent_function(node)
        if function_node then
          node = function_node
        else
          while node:parent() and node:parent():type() ~= 'module' do
            local parent = node:parent()
            if is_executable_node(parent:type()) then
              node = parent
            else
              break
            end
          end
        end
      end
    end
  end

  if node:type() == 'string' then
    while node:parent() and node:parent():type() == 'string' do
      node = node:parent()
    end
  end

  local start_row, start_col, end_row, end_col = node:range()

  if start_row == end_row then
    start_col = 0
    end_col = -1
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col + 1, end_col)
  else
    lines[1] = string.sub(lines[1], start_col + 1)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  local code = table.concat(lines, '\n')

  iron.send(vim.bo.filetype, code)
end

return M
