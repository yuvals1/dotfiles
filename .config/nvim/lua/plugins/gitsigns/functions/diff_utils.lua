-- File: lua/plugins/gitsigns/functions/diff_utils.lua

local M = {}
local utils = require 'plugins.gitsigns.functions.utils'

-- Function to copy the full diff of the file
function M.copy_file_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local git_root, relpath = utils.get_git_root_and_relpath(bufnr)
  if not git_root then
    return
  end

  local cmd = { 'git', '-C', git_root, 'diff', '--', relpath }
  local result = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    print 'Failed to get diff'
    return
  end
  if #result == 0 then
    print 'No changes to copy'
    return
  end

  vim.fn.setreg('+', table.concat(result, '\n'))
  print 'File diff copied to clipboard'
end

-- Function to copy the staged diff of the file
function M.copy_staged_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local git_root, relpath = utils.get_git_root_and_relpath(bufnr)
  if not git_root then
    return
  end

  local cmd = { 'git', '-C', git_root, 'diff', '--cached', '--', relpath }
  local result = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    print 'Failed to get staged diff'
    return
  end
  if #result == 0 then
    print 'No staged changes to copy'
    return
  end

  vim.fn.setreg('+', table.concat(result, '\n'))
  print 'Staged diff copied to clipboard'
end

return M
