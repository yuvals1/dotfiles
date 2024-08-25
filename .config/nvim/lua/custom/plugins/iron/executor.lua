-- File: lua/custom/plugins/iron/executor.lua
local repl = require 'custom.plugins.iron.repl'
local cells = require 'custom.plugins.iron.cells'
local analyzer = require 'custom.plugins.iron.analyzer'
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

M.execute_cell = function()
  local code = cells.get_cell_content()
  local start_line = vim.fn.search('^# %%', 'bnW') + 1
  local end_line = vim.fn.search('^# %%', 'nW') - 1
  if end_line == -1 then
    end_line = vim.fn.line '$'
  end
  repl.send_to_repl(code, start_line, end_line, 'cell')
end

M.execute_cell_and_move = function()
  M.execute_cell()
  cells.move_to_next_cell()
end

M.smart_execute = function()
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    -- Visual mode: send selected text
    local start_line = vim.fn.line "'<"
    local end_line = vim.fn.line "'>"
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local code = table.concat(lines, '\n')
    repl.send_to_repl(code, start_line, end_line, 'visual')
  else
    -- Normal mode: existing logic
    if not is_current_line_empty() then
      local node = analyzer.get_executable_node()
      if node then
        local code = analyzer.get_node_text(node)
        local start_row, _, end_row, _ = node:range()
        repl.send_to_repl(code, start_row + 1, end_row + 1, 'smart')
      end
    end
    -- No message is printed for empty lines
  end
end

M.smart_execute_and_move = function()
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    -- Visual mode: send selected text and move to end of selection
    local start_line = vim.fn.line "'<"
    local end_line = vim.fn.line "'>"
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local code = table.concat(lines, '\n')
    repl.send_to_repl(code, start_line, end_line, 'visual')
    vim.api.nvim_input '<Esc>`>'
  else
    -- Normal mode: existing logic
    if is_current_line_empty() then
      local row, col = ensure_valid_cursor_position(vim.fn.line '.' + 1, 0)
      vim.api.nvim_win_set_cursor(0, { row, col })
    else
      local node = analyzer.get_executable_node()
      if node then
        local code = analyzer.get_node_text(node)
        local start_row, _, end_row, _ = node:range()
        repl.send_to_repl(code, start_row + 1, end_row + 1, 'smart')

        -- Move to the line after the executed block
        local row, col = ensure_valid_cursor_position(end_row + 2, 0)
        vim.api.nvim_win_set_cursor(0, { row, col })
      end
    end
  end
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
