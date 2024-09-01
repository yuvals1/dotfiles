-- File: lua/custom/plugins/iron/execution_tracker.lua
local M = {}

local current_execution = {
  start_line = nil,
  end_line = nil,
  execution_type = nil,
  bufnr = nil,
}

local sign_id = 1

M.track_execution = function(start_line, end_line, execution_type, bufnr)
  current_execution.start_line = start_line
  current_execution.end_line = end_line
  current_execution.execution_type = execution_type
  current_execution.bufnr = bufnr
end

M.mark_executed_lines = function()
  if not current_execution.bufnr then
    return
  end

  -- Define a sign group for our execution markers
  vim.fn.sign_define('IronExecuted', { text = '▌', texthl = 'IronExecutedSign' })

  local start_line = current_execution.start_line
  local end_line = current_execution.end_line

  if current_execution.execution_type == 'file' then
    start_line = 1
    end_line = vim.api.nvim_buf_line_count(current_execution.bufnr)
  elseif current_execution.execution_type == 'until_cursor' then
    start_line = 1
    end_line = vim.fn.line '.'
  end

  -- Place signs for each executed line
  for line = start_line, end_line do
    vim.fn.sign_place(sign_id, 'IronExecutionGroup', 'IronExecuted', current_execution.bufnr, { lnum = line })
    sign_id = sign_id + 1
  end

  -- Mark empty lines between signs
  M.mark_empty_lines_between_signs()
end

M.mark_empty_lines_between_signs = function()
  local bufnr = current_execution.bufnr
  local signs = vim.fn.sign_getplaced(bufnr, { group = 'IronExecutionGroup' })[1].signs
  local signed_lines = {}

  for _, sign in ipairs(signs) do
    table.insert(signed_lines, sign.lnum)
  end

  table.sort(signed_lines)

  for i = 1, #signed_lines - 1 do
    local start_line = signed_lines[i]
    local end_line = signed_lines[i + 1]

    if end_line - start_line > 1 then
      local all_empty = true
      for line = start_line + 1, end_line - 1 do
        local content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
        if content and content:match '%S' then
          all_empty = false
          break
        end
      end

      if all_empty then
        for line = start_line + 1, end_line - 1 do
          vim.fn.sign_place(sign_id, 'IronExecutionGroup', 'IronExecuted', bufnr, { lnum = line })
          sign_id = sign_id + 1
        end
      end
    end
  end
end

M.clean_execution_marks = function()
  vim.fn.sign_unplace 'IronExecutionGroup'
  sign_id = 1 -- Reset sign ID
  current_execution = {
    start_line = nil,
    end_line = nil,
    execution_type = nil,
    bufnr = nil,
  }
end

M.get_first_non_executed_line = function()
  if not current_execution.bufnr then
    return 1
  end

  local signs = vim.fn.sign_getplaced(current_execution.bufnr, { group = 'IronExecutionGroup' })[1].signs
  local executed_lines = {}

  for _, sign in ipairs(signs) do
    executed_lines[sign.lnum] = true
  end

  local total_lines = vim.api.nvim_buf_line_count(current_execution.bufnr)
  for line = 1, total_lines do
    if not executed_lines[line] then
      return line
    end
  end

  return total_lines + 1 -- If all lines are executed, return the line after the last one
end

return M
