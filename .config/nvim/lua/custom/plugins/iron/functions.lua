local iron = require 'iron.core'

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

return M
