-- File: lua/custom/plugins/iron/executor.lua
local repl = require 'custom.plugins.iron.repl'
local iron = require 'iron.core'

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

M.execute_until_cursor = function()
  local cursor_line = vim.fn.line '.'
  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)
  local code = table.concat(lines, '\n')
  repl.send_to_repl(code, 1, cursor_line, 'until_cursor')
end

return M
