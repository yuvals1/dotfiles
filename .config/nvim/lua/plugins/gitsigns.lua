return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Define a function to find the hunk at the cursor
        local function find_hunk(lnum, hunks)
          for _, hunk in ipairs(hunks) do
            local hunk_start = math.min(hunk.added.start, hunk.removed.start)
            local hunk_end = math.max(hunk.added.start + hunk.added.count - 1, hunk.removed.start + hunk.removed.count - 1)
            if lnum >= hunk_start and lnum <= hunk_end then
              return hunk, hunk_start, hunk_end
            end
          end
        end

        -- Define the custom function to copy the hunk
        local function copy_hunk()
          local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
          local hunks = gitsigns.get_hunks(bufnr)
          if not hunks then
            print 'No hunks available'
            return
          end

          local hunk, _, _ = find_hunk(cursor_line, hunks)
          if hunk then
            vim.fn.setreg('+', table.concat(hunk.lines, '\n'))
            print 'Hunk copied to clipboard'
          else
            print 'No hunk found at cursor position'
          end
        end

        -- Define the custom function to copy the full diff of the file
        local function copy_file_diff()
          local filepath = vim.api.nvim_buf_get_name(bufnr)
          if filepath == '' then
            print 'No file name available'
            return
          end

          -- Get the Git root directory
          local git_root = vim.fn.trim(vim.fn.system('git -C "' .. vim.fn.fnamemodify(filepath, ':h') .. '" rev-parse --show-toplevel'))
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

        -- Navigation
        map('n', 'L', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git hunk' })
        map('n', 'H', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git hunk' })

        -- Actions
        -- Visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset git hunk' })

        -- Normal mode
        map('n', 'M', gitsigns.stage_hunk, { desc = 'Git stage hunk' })
        map('n', 'R', gitsigns.reset_hunk, { desc = 'Git reset hunk' })
        map('n', 'P', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
        map('n', '<leader>hs', gitsigns.stage_buffer, { desc = 'Git stage buffer' })
        map('n', '<leader>hm', gitsigns.stage_buffer, { desc = 'Git stage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Git undo stage hunk' })
        map('n', '<leader>hr', gitsigns.reset_buffer, { desc = 'Git reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git preview hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git blame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git diff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git diff against last commit' })

        -- Copy hunk to clipboard
        map('n', '<leader>hc', copy_hunk, { desc = 'Copy hunk to clipboard' })

        -- Copy file diff to clipboard
        map('n', '<leader>hC', copy_file_diff, { desc = 'Copy file diff to clipboard' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle git blame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = 'Toggle git deleted lines' })
      end,
    },
  },
}
