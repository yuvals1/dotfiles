-- File: lua/plugins/gitsigns/keymaps.lua

local M = {}

function M.setup(bufnr)
  local gitsigns = require 'gitsigns'
  local functions = require 'plugins.gitsigns.functions'

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
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
    local start_line = vim.fn.line 'v'
    local end_line = vim.fn.line '.'
    gitsigns.stage_hunk { math.min(start_line, end_line), math.max(start_line, end_line) }
  end, { desc = 'Stage git hunk' })

  map('v', '<leader>hr', function()
    local start_line = vim.fn.line 'v'
    local end_line = vim.fn.line '.'
    gitsigns.reset_hunk { math.min(start_line, end_line), math.max(start_line, end_line) }
  end, { desc = 'Reset git hunk' })

  -- Actions in Normal Mode
  map('n', 'M', gitsigns.stage_hunk, { desc = 'Git stage hunk' })
  map('n', 'R', gitsigns.reset_hunk, { desc = 'Git reset hunk' })
  map('n', 'P', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
  map('n', '<leader>hm', gitsigns.stage_buffer, { desc = 'Git stage buffer' })
  map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Git undo stage hunk' })
  map('n', '<leader>hr', gitsigns.reset_buffer, { desc = 'Git reset buffer' })
  map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
  map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git blame line' })
  map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git diff against index' })
  map('n', '<leader>hD', function()
    gitsigns.diffthis '~'
  end, { desc = 'Git diff against last commit' })

  -- Clipboard Actions
  map('n', '<leader>hc', functions.copy_hunk, { desc = 'Copy hunk to clipboard' })
  map('n', '<leader>ha', functions.append_hunk_to_clipboard, { desc = 'Append hunk to clipboard' })
  map('n', '<leader>hC', functions.copy_file_diff, { desc = 'Copy file diff to clipboard' })
  map('n', '<leader>hs', functions.copy_staged_diff, { desc = 'Copy staged diff to clipboard' })
  map('n', '<leader>hx', functions.clear_clipboard, { desc = 'Clear clipboard' })

  -- Toggles
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle git blame line' })
  map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = 'Toggle git deleted lines' })
end

return M
