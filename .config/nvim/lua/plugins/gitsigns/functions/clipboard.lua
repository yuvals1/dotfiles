-- File: lua/plugins/gitsigns/functions/clipboard.lua

local M = {}
local hunk_utils = require 'plugins.gitsigns.functions.hunk_utils'

-- Function to copy the hunk to the clipboard
function M.copy_hunk()
  local bufnr = vim.api.nvim_get_current_buf()
  local hunk = hunk_utils.find_hunk_at_cursor(bufnr)
  if hunk then
    vim.fn.setreg('+', table.concat(hunk.lines, '\n'))
    print 'Hunk copied to clipboard'
  else
    print 'No hunk found at cursor position'
  end
end

-- Function to append the hunk to the clipboard
function M.append_hunk_to_clipboard()
  local bufnr = vim.api.nvim_get_current_buf()
  local hunk = hunk_utils.find_hunk_at_cursor(bufnr)
  if hunk then
    local hunk_text = table.concat(hunk.lines, '\n')
    local current_clipboard = vim.fn.getreg '+'
    local new_clipboard = current_clipboard ~= '' and (current_clipboard .. '\n' .. hunk_text) or hunk_text
    vim.fn.setreg('+', new_clipboard)
    print 'Hunk appended to clipboard'
  else
    print 'No hunk found at cursor position'
  end
end

-- Function to clear the clipboard
function M.clear_clipboard()
  vim.fn.setreg('+', '')
  print 'Clipboard cleared'
end

return M
