-- File: lua/custom/plugins/iron/executor.lua
local repl = require 'custom.plugins.iron.repl'
local cells = require 'custom.plugins.iron.cells'
local analyzer = require 'custom.plugins.iron.analyzer'

local M = {}

-- New helper function to check if the current line is empty
local function is_current_line_empty()
  local current_line = vim.api.nvim_get_current_line()
  return current_line:match '^%s*$' ~= nil
end

M.execute_line = function()
  local current_line = vim.api.nvim_get_current_line()
  repl.send_to_repl(current_line)
end

M.execute_line_and_move = function()
  M.execute_line()

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

M.execute_cell = function()
  local code = cells.get_cell_content()
  repl.send_to_repl(code)
end

M.execute_cell_and_move = function()
  M.execute_cell()
  cells.move_to_next_cell()
end

M.smart_execute = function()
  if not is_current_line_empty() then
    local node = analyzer.get_executable_node()
    if node then
      local code = analyzer.get_node_text(node)
      repl.send_to_repl(code)
    end
  end
  -- No message is printed for empty lines
end

M.smart_execute_and_move = function()
  if is_current_line_empty() then
    vim.cmd 'normal! j'
  else
    local node = analyzer.get_executable_node()
    if node then
      local code = analyzer.get_node_text(node)
      repl.send_to_repl(code)

      -- Move to the line after the executed block
      local _, _, end_row, _ = node:range()
      vim.api.nvim_win_set_cursor(0, { end_row + 2, 0 })
    end
  end
  -- No message is printed for empty lines
end

return M
