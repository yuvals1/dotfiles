local M = {}

function M.setup(bufnr)
  local gitsigns = require 'gitsigns'
  local clipboard = require 'plugins.gitsigns.functions.clipboard'
  local diff_utils = require 'plugins.gitsigns.functions.diff_utils'
  local toggle = require 'plugins.gitsigns.functions.toggle'

  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Navigation
  map('n', 'L', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      gitsigns.next_hunk()
    end
  end, { desc = 'Jump to next git hunk' })

  map('n', 'H', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      gitsigns.prev_hunk()
    end
  end, { desc = 'Jump to previous git hunk' })

  -- Actions in Visual Mode
  map('v', '<leader>hs', function()
    local s = vim.fn.line 'v'
    local e = vim.fn.line '.'
    gitsigns.stage_hunk { math.min(s, e), math.max(s, e) }
  end, { desc = 'Stage selected hunk' })

  map('v', '<leader>hr', function()
    local s = vim.fn.line 'v'
    local e = vim.fn.line '.'
    gitsigns.reset_hunk { math.min(s, e), math.max(s, e) }
  end, { desc = 'Reset selected hunk' })

  -- Actions in Normal Mode
  -- map('n', 'M', gitsigns.stage_hunk, { desc = 'Stage current hunk' })
  map('n', 'R', gitsigns.reset_hunk, { desc = 'Reset current hunk' })
  map('n', 'P', gitsigns.preview_hunk, { desc = 'Preview current hunk' })

  -- Toggle Stage/Unstage Buffer
  map('n', '<leader>hm', toggle.toggle_stage_buffer, { desc = 'Toggle stage/unstage buffer' })

  map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Undo last stage hunk' })
  map('n', '<leader>hr', gitsigns.reset_buffer, { desc = 'Reset buffer' })
  map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
  map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Blame current line' })
  map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff against index' })
  map('n', '<leader>hD', function()
    gitsigns.diffthis '~'
  end, { desc = 'Diff against last commit' })

  -- Clipboard Actions
  map('n', '<leader>hc', clipboard.copy_hunk, { desc = 'Copy hunk to clipboard' })
  map('n', '<leader>ha', clipboard.append_hunk_to_clipboard, { desc = 'Append hunk to clipboard' })
  map('n', '<leader>hC', diff_utils.copy_file_diff, { desc = 'Copy file diff to clipboard' })
  map('n', '<leader>hs', diff_utils.copy_staged_diff, { desc = 'Copy staged diff to clipboard' })
  map('n', '<leader>hx', clipboard.clear_clipboard, { desc = 'Clear clipboard' })

  -- Toggles
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle blame line' })
  map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = 'Toggle deleted lines' })
end

return M
