-- File: lua/custom/plugins/iron/analyzer.lua
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

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
    or node_type == 'assignment' -- Added for multiline assignments
    or node_type == 'binary_operator' -- Added for long calculations
    or node_type == 'parenthesized_expression' -- Added for expressions in parentheses
    or node_type == 'tuple' -- Added for multiline tuples
    or node_type == 'list' -- Added for multiline lists
    or node_type == 'dictionary' -- Added for multiline dictionaries
    or node_type == 'call' -- Added for multiline function calls
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

M.get_executable_node = function()
  if vim.bo.filetype ~= 'python' then
    print 'This function is only for Python files.'
    return nil
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then
    print 'No executable construct found at cursor.'
    return nil
  end

  -- Check if we're on an empty line or a line with only whitespace
  local line = vim.api.nvim_get_current_line()
  if line:match '^%s*$' then
    print 'Cursor is on an empty line. No code to execute.'
    return nil
  end

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

  return node
end

M.get_node_text = function(node)
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

  return table.concat(lines, '\n')
end

return M
