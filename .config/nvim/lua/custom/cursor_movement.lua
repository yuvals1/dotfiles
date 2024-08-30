local M = {}

local function move_cursor_right()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  if col < #line then
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
  elseif row < vim.api.nvim_buf_line_count(0) then
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  end
end

local function move_cursor_left()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  if col > 0 then
    vim.api.nvim_win_set_cursor(0, { row, col - 1 })
  elseif row > 1 then
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
    vim.api.nvim_win_set_cursor(0, { row - 1, #prev_line })
  end
end

function M.setup()
  vim.keymap.set('i', '<C-f>', move_cursor_right, { noremap = true, silent = true })
  vim.keymap.set('i', '<C-b>', move_cursor_left, { noremap = true, silent = true })
end

return M
