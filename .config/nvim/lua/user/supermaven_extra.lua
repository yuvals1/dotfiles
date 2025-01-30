local M = {}

function M.accept_next_char()
  -- 1. Grab the plugin’s own modules
  local completion_preview = require 'supermaven-nvim.completion_preview'

  -- We call accept_completion_text with `true` to get partial completion text
  local accept_completion = completion_preview:accept_completion_text(true)
  if not accept_completion or not accept_completion.is_active then
    -- Fall back to normal <Tab> if no suggestion is active
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', true)
    return
  end

  -- 2. We have partial completion text (usually “next word”) in `completion_text`.
  --    We only want the next *character*:
  local completion_text = accept_completion.completion_text
  if #completion_text > 0 then
    completion_text = completion_text:sub(1, 1)
  end

  -- 3. The rest is basically the same text‐edit logic from plugin’s
  --    on_accept_suggestion(...) function:
  local prior_delete = accept_completion.prior_delete
  local cursor = vim.api.nvim_win_get_cursor(0)
  local range = {
    start = { line = cursor[1] - 1, character = math.max(cursor[2] - prior_delete, 0) },
    ['end'] = { line = cursor[1] - 1, character = vim.fn.col '$' },
  }

  -- This feedkeys+replace_termcodes hack is how the plugin forces removal
  -- of any popup or completion. You can mimic it exactly or skip it.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Space><Left><Del>', true, false, true), 'n', false)

  -- Now apply the text change as an LSP edit
  vim.lsp.util.apply_text_edits({ { range = range, newText = completion_text } }, vim.api.nvim_get_current_buf(), 'utf-8')

  -- 4. Move the cursor forward appropriately
  --    (similar to how supermaven does it)
  local lines = 0
  for _ in completion_text:gmatch '\n' do
    lines = lines + 1
  end

  local last_line = completion_text
  do
    -- figure out if there’s a newline in the text
    local match_start = completion_text:match '.*()\n'
    if match_start then
      last_line = completion_text:sub(match_start + 1)
    end
  end

  local new_cursor_pos = { cursor[1] + lines, cursor[2] + #last_line + 1 }
  vim.api.nvim_win_set_cursor(0, new_cursor_pos)
end

return M
