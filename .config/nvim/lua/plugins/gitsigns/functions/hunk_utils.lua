-- File: lua/plugins/gitsigns/functions/hunk_utils.lua

local M = {}

-- Function to find the hunk at the cursor
function M.find_hunk_at_cursor(bufnr)
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunks = require('gitsigns').get_hunks(bufnr)
  if not hunks then
    return
  end

  for _, hunk in ipairs(hunks) do
    local hunk_start = hunk.added.start
    local hunk_end = hunk.added.start + hunk.added.count - 1
    if cursor_line >= hunk_start and cursor_line <= hunk_end then
      return hunk
    end
  end
end

return M
