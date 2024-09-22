-- test_clipboard_clear.lua

local clipboard_utils = require 'clipboard_utils'

local function test_clear_clipboard()
  -- Simulate copying content
  clipboard_utils.copy_file_path_and_content()
  clipboard_utils.append_file_path_and_content()

  -- Ensure temporary files exist
  local tmp_content_file = '/tmp/clipboard_content.txt'
  local tmp_metadata_file = '/tmp/clipboard_metadata.txt'

  assert(vim.loop.fs_stat(tmp_content_file), 'Content file does not exist before clearing')
  assert(vim.loop.fs_stat(tmp_metadata_file), 'Metadata file does not exist before clearing')

  -- Call the clear_clipboard function
  local lines_cleared = clipboard_utils.clear_clipboard()

  -- Check if temporary files are deleted
  assert(not vim.loop.fs_stat(tmp_content_file), 'Content file still exists after clearing')
  assert(not vim.loop.fs_stat(tmp_metadata_file), 'Metadata file still exists after clearing')

  print 'Clipboard clear test passed successfully!'
  print('Lines cleared: ' .. lines_cleared)
end

-- Run the test
test_clear_clipboard()
