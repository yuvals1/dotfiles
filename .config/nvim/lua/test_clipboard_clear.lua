-- test_clipboard_visual_append.lua

local clipboard_utils = require 'clipboard_utils'

local function test_append_visual_selection()
  -- Simulate visual selection
  local test_content = 'This is a test snippet\nWith multiple lines'
  local tmp_content_file = '/tmp/clipboard_content.txt'

  -- Clear any existing temp file
  os.remove(tmp_content_file)

  -- Mock the get_visual_selection function
  local original_get_visual_selection = clipboard_utils.get_visual_selection
  clipboard_utils.get_visual_selection = function()
    return test_content
  end

  -- Call the append_visual_selection function
  local snippet_number, lines_added = clipboard_utils.append_visual_selection()

  -- Restore the original function
  clipboard_utils.get_visual_selection = original_get_visual_selection

  -- Verify that the snippet was appended
  local content_file = io.open(tmp_content_file, 'r')
  assert(content_file, 'Content file does not exist after appending snippet')
  local content = content_file:read '*a'
  content_file:close()
  assert(content:find(test_content), 'Snippet content not found in content file')

  -- Verify snippet number
  assert(snippet_number == 1, 'Snippet number is not 1 as expected')

  -- Verify lines added
  assert(lines_added == 2, 'Snippet line count is incorrect')

  print 'Visual snippet append test passed successfully!'
  print('Snippet number: ' .. snippet_number)
end

-- Run the test
test_append_visual_selection()
