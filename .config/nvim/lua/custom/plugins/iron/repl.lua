-- File: lua/custom/plugins/iron/repl.lua
local iron_core = require 'iron.core'
local execution_tracker = require 'custom.plugins.iron.execution_tracker'

local M = {}

-- Create a custom highlight group for executed code
vim.api.nvim_command 'highlight IronExecutedCode guibg=#2ecc71 guifg=black'

M.custom_repl_open_cmd = function(bufnr)
  local width = math.floor(vim.o.columns * 0.3)
  vim.cmd('silent! botright vertical ' .. width .. 'split')
  vim.api.nvim_win_set_buf(0, bufnr)
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
  return win
end

M.send_to_repl = function(code, start_line, end_line, execution_type)
  -- Store the current buffer
  local current_buf = vim.api.nvim_get_current_buf()

  -- Track the execution
  execution_tracker.track_execution(start_line, end_line, execution_type, current_buf)

  -- Send code to REPL
  iron_core.send(vim.bo.filetype, code)

  -- Switch back to normal mode
  vim.cmd 'stopinsert'
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  -- Mark executed lines
  execution_tracker.mark_executed_lines()

  -- Highlight the executed code
  if start_line and end_line then
    local ns_id = vim.api.nvim_create_namespace 'iron_highlight'

    -- Clear any existing highlights in this namespace
    vim.api.nvim_buf_clear_namespace(current_buf, ns_id, 0, -1)

    -- Add highlight to each line in the range
    for i = start_line - 1, end_line - 1 do
      vim.api.nvim_buf_add_highlight(current_buf, ns_id, 'IronExecutedCode', i, 0, -1)
    end

    -- Clear the highlight after a short delay
    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(current_buf, ns_id, 0, -1)
    end, 200) -- 200ms delay, adjust as needed
  end
end

-- Updated function to clear signs, restart REPL, ensure normal mode, and dismiss Noice notification
M.clear_and_restart = function()
  -- Clear signs
  execution_tracker.clean_execution_marks()

  -- Restart REPL
  iron_core.repl_restart(vim.bo.filetype)

  -- Ensure we're in normal mode
  vim.cmd 'stopinsert'
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  -- Dismiss Noice notification
  vim.defer_fn(function()
    require('noice').cmd 'dismiss'
  end, 10) -- Small delay to ensure the restart message appears before dismissing
end

return M
