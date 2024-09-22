-- File: lua/plugins/gitsigns/functions/toggle.lua

local M = {}
local utils = require 'plugins.gitsigns.functions.utils'

-- Function to check if the file is staged
local function is_file_staged(git_root, relpath)
  local staged_files = vim.fn.systemlist { 'git', '-C', git_root, 'diff', '--name-only', '--cached' }
  if vim.tbl_contains(staged_files, relpath) then
    return true
  else
    return false
  end
end

-- Toggle function to stage or unstage the buffer
function M.toggle_stage_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local git_root, relpath = utils.get_git_root_and_relpath(bufnr)
  if not git_root then
    return
  end

  if is_file_staged(git_root, relpath) then
    -- Unstage the file
    local git_cmd = { 'git', '-C', git_root, 'reset', 'HEAD', '--', relpath }
    local result = vim.fn.systemlist(git_cmd)
    if vim.v.shell_error ~= 0 then
      print('Failed to unstage file: ' .. table.concat(result, '\n'))
      return
    end
    print 'File unstaged'
  else
    -- Stage the buffer
    require('gitsigns').stage_buffer()
    print 'File staged'
  end

  -- Refresh gitsigns to update signs
  require('gitsigns').refresh()
end

return M
