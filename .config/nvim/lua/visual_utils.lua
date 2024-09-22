-- visual_utils.lua

local M = {}

-- Function to highlight the entire buffer
function M.highlight_entire_buffer()
  local ns_id = vim.api.nvim_create_namespace 'highlight_yac'
  local buf = 0 -- Current buffer
  local start_pos = { 0, 0 } -- Start at line 0, column 0
  local end_line = vim.api.nvim_buf_line_count(buf) - 1
  -- Handle empty buffer case
  local end_col = 0
  if end_line >= 0 then
    local last_line = vim.api.nvim_buf_get_lines(buf, end_line, end_line + 1, false)[1]
    end_col = last_line and #last_line or 0
  end
  vim.highlight.range(buf, ns_id, 'IncSearch', start_pos, { end_line, end_col }, { inclusive = true })
  -- Clear the highlight after a timeout
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  end, 150)
end

-- Function to highlight the visual selection
function M.highlight_selection()
  local ns_id = vim.api.nvim_create_namespace 'highlight_yav'
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, '<')
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, '>')

  local start_line = start_pos[1] - 1 -- Convert to 0-based indexing
  local start_col = start_pos[2]
  local end_line = end_pos[1] - 1
  local end_col = end_pos[2]

  vim.highlight.range(bufnr, ns_id, 'IncSearch', { start_line, start_col }, { end_line, end_col }, { inclusive = true })

  -- Clear the highlight after a timeout
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end, 150)
end

return M
