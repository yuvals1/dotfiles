-- File: lua/plugins/gitsigns/functions/utils.lua

local M = {}

-- Function to get the Git root directory and relative path of the current file
function M.get_git_root_and_relpath(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then
    print 'No file name available'
    return
  end

  local git_root_cmd = 'git -C "' .. vim.fn.fnamemodify(filepath, ':h') .. '" rev-parse --show-toplevel'
  local git_root = vim.fn.trim(vim.fn.system(git_root_cmd))
  if git_root == '' then
    print 'Not inside a Git repository'
    return
  end

  local uv = vim.loop
  local real_filepath = uv.fs_realpath(filepath)
  local real_git_root = uv.fs_realpath(git_root)
  if not real_filepath or not real_git_root or not real_filepath:find('^' .. real_git_root) then
    print 'File is not inside the Git repository'
    return
  end

  local relpath = real_filepath:sub(#real_git_root + 2)
  return real_git_root, relpath
end

return M
