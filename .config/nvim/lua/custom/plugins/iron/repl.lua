-- File: lua/custom/plugins/iron/repl.lua
local iron_core = require 'iron.core'
local execution_tracker = require 'custom.plugins.iron.execution_tracker'

local M = {}

-- Create a custom highlight group for executed code
vim.api.nvim_command 'highlight IronExecutedCode guibg=#2ecc71 guifg=black'

-- New variables for highlight management
local highlight_timer = nil
local current_highlight_ns = nil

M.custom_repl_open_cmd = function(bufnr)
  local position = vim.g.iron_repl_position
  local cmd

  if position == 'bottom' then
    local height = math.floor(vim.o.lines * 0.2)
    cmd = 'silent! botright ' .. height .. 'split'
  else
    local width = math.floor(vim.o.columns * 0.3)
    cmd = 'silent! botright vertical ' .. width .. 'split'
  end

  vim.cmd(cmd)
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
    -- Clear any existing timer
    if highlight_timer then
      vim.fn.timer_stop(highlight_timer)
    end

    -- Clear existing highlight if any
    if current_highlight_ns then
      vim.api.nvim_buf_clear_namespace(current_buf, current_highlight_ns, 0, -1)
    end

    -- Create a new namespace for this highlight
    current_highlight_ns = vim.api.nvim_create_namespace('iron_highlight_' .. os.time())

    -- Add highlight to each line in the range
    for i = start_line - 1, end_line - 1 do
      vim.api.nvim_buf_add_highlight(current_buf, current_highlight_ns, 'IronExecutedCode', i, 0, -1)
    end

    -- Set a new timer to clear the highlight
    highlight_timer = vim.fn.timer_start(400, function()
      vim.schedule(function()
        if current_highlight_ns then
          vim.api.nvim_buf_clear_namespace(current_buf, current_highlight_ns, 0, -1)
          current_highlight_ns = nil
        end
      end)
    end)
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
  end, 50) -- Small delay to ensure the restart message appears before dismissing
end

return M
