-- File: lua/custom/plugins/iron/repl.lua
local iron_core = require 'iron.core'

local M = {}

-- Create a custom highlight group for executed code
vim.api.nvim_command 'highlight IronExecutedCode guibg=#2ecc71 guifg=black'

-- Initialize sign ID
local sign_id = 1

-- New function to place execution signs
local function place_execution_signs(start_line, end_line)
  -- Define a sign group for our execution markers
  vim.fn.sign_define('IronExecuted', { text = '▌', texthl = 'IronExecutedSign' })

  -- Place signs for each executed line
  for line = start_line, end_line do
    vim.fn.sign_place(sign_id, 'IronExecutionGroup', 'IronExecuted', vim.api.nvim_get_current_buf(), { lnum = line })
    sign_id = sign_id + 1
  end
end

-- New function to mark empty lines between signs
local function mark_empty_lines_between_signs()
  local bufnr = vim.api.nvim_get_current_buf()
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

-- Function to clean execution signs
M.clean_signs = function()
  vim.fn.sign_unplace 'IronExecutionGroup'
  sign_id = 1 -- Reset sign ID
end

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

M.send_to_repl = function(code, start_line, end_line)
  -- Store the current buffer
  local current_buf = vim.api.nvim_get_current_buf()

  -- Send code to REPL
  iron_core.send(vim.bo.filetype, code)

  -- Switch back to normal mode
  vim.cmd 'stopinsert'
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  -- Highlight the executed code
  if start_line and end_line then
    local ns_id = vim.api.nvim_create_namespace 'iron_highlight'

    -- Clear any existing highlights in this namespace
    vim.api.nvim_buf_clear_namespace(current_buf, ns_id, 0, -1)

    -- Add highlight to each line in the range
    for i = start_line - 1, end_line - 1 do
      vim.api.nvim_buf_add_highlight(current_buf, ns_id, 'IronExecutedCode', i, 0, -1)
    end

    -- Place execution signs
    place_execution_signs(start_line, end_line)

    -- Mark empty lines between signs
    mark_empty_lines_between_signs()

    -- Clear the highlight after a short delay
    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(current_buf, ns_id, 0, -1)
    end, 200) -- 200ms delay, adjust as needed
  end
end

-- Updated function to clear signs, restart REPL, ensure normal mode, and dismiss Noice notification
M.clear_and_restart = function()
  -- Clear signs
  M.clean_signs()

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
