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

  -- Get the start and end positions of the visual selection
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(bufnr, '<'))
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(bufnr, '>'))

  -- Adjust for Vim's inclusive selection
  end_col = end_col + 1

  -- Get the content of the last selected line
  local last_line_content = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1]

  -- Ensure end_col doesn't exceed the length of the last line
  end_col = math.min(end_col, #last_line_content)

  -- Apply the highlight
  vim.highlight.range(bufnr, ns_id, 'IncSearch', { start_line - 1, start_col }, { end_line - 1, end_col }, { inclusive = true })

  -- Clear the highlight after a timeout
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end, 150)
end

return M
