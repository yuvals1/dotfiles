-- File: lua/custom/plugins/iron/executor.lua
local repl = require 'custom.plugins.iron.repl'
local cells = require 'custom.plugins.iron.cells'
local analyzer = require 'custom.plugins.iron.analyzer'
local iron = require 'iron.core'

local M = {}

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
  repl.send_to_repl(current_line_content, current_line, current_line)
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
  repl.send_to_repl(code, start_line, end_line)
end

M.execute_cell_and_move = function()
  M.execute_cell()
  cells.move_to_next_cell()
end

M.smart_execute = function()
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    -- Visual mode: send selected text
    iron.visual_send()
  else
    -- Normal mode: existing logic
    if not is_current_line_empty() then
      local node = analyzer.get_executable_node()
      if node then
        local code = analyzer.get_node_text(node)
        local start_row, _, end_row, _ = node:range()
        repl.send_to_repl(code, start_row + 1, end_row + 1)
      end
    end
    -- No message is printed for empty lines
  end
end

M.smart_execute_and_move = function()
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
    -- Visual mode: send selected text and move to end of selection
    iron.visual_send()
    vim.api.nvim_input '<Esc>`>'
  else
    -- Normal mode: existing logic
    if is_current_line_empty() then
      ensure_next_line()
      vim.cmd 'normal! j'
    else
      local node = analyzer.get_executable_node()
      if node then
        local code = analyzer.get_node_text(node)
        local start_row, _, end_row, _ = node:range()
        repl.send_to_repl(code, start_row + 1, end_row + 1)

        local created_new_line = ensure_next_line()

        -- Move to the line after the executed block
        vim.api.nvim_win_set_cursor(0, { end_row + 2, created_new_line and vim.fn.col '$' - 1 or 0 })
      end
    end
  end
end

return M
