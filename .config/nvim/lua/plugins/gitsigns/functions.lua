-- File: lua/plugins/gitsigns/functions.lua

local M = {}

local gitsigns = require 'gitsigns'

-- Helper function to find the hunk at the cursor
local function find_hunk(lnum, hunks)
  for _, hunk in ipairs(hunks) do
    local hunk_start = hunk.added.start
    local hunk_end = hunk.added.start + hunk.added.count - 1
    if lnum >= hunk_start and lnum <= hunk_end then
      return hunk
    end
  end
end

-- Function to copy the hunk to the clipboard
function M.copy_hunk()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks then
    print 'No hunks available'
    return
  end

  local hunk = find_hunk(cursor_line, hunks)
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
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks then
    print 'No hunks available'
    return
  end

  local hunk = find_hunk(cursor_line, hunks)
  if hunk then
    local hunk_text = table.concat(hunk.lines, '\n')
    local current_clipboard = vim.fn.getreg '+'
    if current_clipboard ~= '' then
      current_clipboard = current_clipboard .. '\n' .. hunk_text
    else
      current_clipboard = hunk_text
    end
    vim.fn.setreg('+', current_clipboard)
    print 'Hunk appended to clipboard'
  else
    print 'No hunk found at cursor position'
  end
end

-- Function to copy the full diff of the file
function M.copy_file_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then
    print 'No file name available'
    return
  end

  -- Get the Git root directory
  local git_root_cmd = 'git -C "' .. vim.fn.fnamemodify(filepath, ':h') .. '" rev-parse --show-toplevel'
  local git_root = vim.fn.trim(vim.fn.system(git_root_cmd))
  if git_root == '' then
    print 'Not inside a Git repository'
    return
  end

  -- Get the relative path of the file to the Git root
  local uv = vim.loop
  local real_filepath = uv.fs_realpath(filepath)
  local real_git_root = uv.fs_realpath(git_root)
  if not real_filepath or not real_git_root then
    print 'Failed to resolve paths'
    return
  end

  if not real_filepath:find('^' .. real_git_root) then
    print 'File is not inside the Git repository'
    return
  end

  local relpath = real_filepath:sub(#real_git_root + 2)
  local cmd = { 'git', '-C', real_git_root, 'diff', '--', relpath }
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
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then
    print 'No file name available'
    return
  end

  -- Get the Git root directory
  local git_root_cmd = 'git -C "' .. vim.fn.fnamemodify(filepath, ':h') .. '" rev-parse --show-toplevel'
  local git_root = vim.fn.trim(vim.fn.system(git_root_cmd))
  if git_root == '' then
    print 'Not inside a Git repository'
    return
  end

  -- Get the relative path of the file to the Git root
  local uv = vim.loop
  local real_filepath = uv.fs_realpath(filepath)
  local real_git_root = uv.fs_realpath(git_root)
  if not real_filepath or not real_git_root then
    print 'Failed to resolve paths'
    return
  end

  if not real_filepath:find('^' .. real_git_root) then
    print 'File is not inside the Git repository'
    return
  end

  local relpath = real_filepath:sub(#real_git_root + 2)
  local cmd = { 'git', '-C', real_git_root, 'diff', '--cached', '--', relpath }
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

-- Function to clear the clipboard
function M.clear_clipboard()
  vim.fn.setreg('+', '')
  print 'Clipboard cleared'
end

return M
