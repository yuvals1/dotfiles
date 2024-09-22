local clipboard_utils = require 'clipboard_utils'

local function test_clear_clipboard()
  -- First, let's add some content to both registers
  vim.fn.setreg('+', 'Test content for system clipboard')
  vim.fn.setreg('"', 'Test content for default register')

  -- Call the clear_clipboard function
  local lines_cleared = clipboard_utils.clear_clipboard()

  -- Check if both registers are empty
  local system_clipboard_content = vim.fn.getreg '+'
  local default_register_content = vim.fn.getreg '"'

  assert(system_clipboard_content == '', "System clipboard ('+' register) is not empty after clearing")
  assert(default_register_content == '', "Default register ('\"' register) is not empty after clearing")

  print 'Clipboard clear test passed successfully!'
  print('Lines cleared: ' .. lines_cleared)
end

-- Run the test
test_clear_clipboard()
