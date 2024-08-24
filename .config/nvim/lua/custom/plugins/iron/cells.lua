-- File: lua/custom/plugins/iron/cells.lua
local M = {}

M.get_cell_content = function()
  local start_line = vim.fn.search('^# %%', 'bnW')
  local end_line = vim.fn.search('^# %%', 'nW') - 1
  if end_line == -1 then
    end_line = vim.fn.line '$'
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  lines = vim.tbl_filter(function(line)
    return not line:match '^# %%'
  end, lines)

  return table.concat(lines, '\n')
end

M.move_to_next_cell = function()
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

return M
