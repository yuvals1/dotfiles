-- File: lua/custom/plugins/iron/executor.lua
local repl = require 'custom.plugins.iron.repl'
local iron = require 'iron.core'

local M = {}

-- New function to ensure valid cursor position
local function ensure_valid_cursor_position(row, col)
  local line_count = vim.api.nvim_buf_line_count(0)
  if row > line_count then
    -- Append new lines as needed
    local lines_to_append = row - line_count
    local empty_lines = {}
    for _ = 1, lines_to_append do
      table.insert(empty_lines, '')
    end
    vim.api.nvim_buf_set_lines(0, -1, -1, false, empty_lines)
  end
  -- Ensure column is within bounds
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1] or ''
  col = math.min(col, #line)
  return row, col
end

-- Helper function to check if the current line is empty
local function is_current_line_empty()
  local current_line = vim.api.nvim_get_current_line()
  return current_line:match '^%s*$' ~= nil
end

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

M.execute_until_cursor = function()
  local cursor_line = vim.fn.line '.'
  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)
  local code = table.concat(lines, '\n')
  repl.send_to_repl(code, 1, cursor_line, 'until_cursor')
end

return M
