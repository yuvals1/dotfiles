-- File: lua/plugins/gitsigns/functions/utils.lua

local M = {}

-- Function to escape special pattern characters in Lua
function M.escape_pattern(text)
  return text:gsub('([^%w])', '%%%1')
end

-- Function to get the Git root directory and relative path of the current file
function M.get_git_root_and_relpath(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then
    print 'No file name available'
    return
  end

  local dir = vim.fn.fnamemodify(filepath, ':h')
  local result = vim.fn.systemlist { 'git', '-C', dir, 'rev-parse', '--show-toplevel' }
  if vim.v.shell_error ~= 0 then
    print 'Not inside a Git repository'
    return
  end

  local git_root = result[1]

  local uv = vim.loop
  local real_filepath = uv.fs_realpath(filepath)
  local real_git_root = uv.fs_realpath(git_root)

  -- Debug statements
  print('Debug: filepath = ' .. filepath)
  print('Debug: dir = ' .. dir)
  print('Debug: git_root = ' .. git_root)
  print('Debug: real_filepath = ' .. tostring(real_filepath))
  print('Debug: real_git_root = ' .. tostring(real_git_root))

  if not real_filepath or not real_git_root then
    print 'Failed to resolve real paths'
    return
  end

  -- Escape special pattern characters
  local escaped_git_root = M.escape_pattern(real_git_root)

  if not real_filepath:find('^' .. escaped_git_root) then
    print 'File is not inside the Git repository'
    return
  end

  local relpath = real_filepath:sub(#real_git_root + 2)
  print('Debug: relpath = ' .. relpath)
  return real_git_root, relpath
end

return M
