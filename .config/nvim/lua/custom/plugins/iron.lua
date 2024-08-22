return {
  {
    'Vigemus/iron.nvim',
    event = 'VeryLazy',
    config = function()
      local iron = require 'iron.core'
      local view = require 'iron.view'
      local fts = require 'iron.fts'

      -- Custom function to create a right split
      local function custom_repl_open_cmd(bufnr)
        local width = math.floor(vim.o.columns * 0.4)
        vim.cmd('botright vertical ' .. width .. 'split')
        vim.api.nvim_win_set_buf(0, bufnr)
        local win = vim.api.nvim_get_current_win()
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
        return win
      end

      -- Function to execute the current cell
      local function execute_cell()
        local start_line = vim.fn.search('^# %%', 'bnW')
        local end_line = vim.fn.search('^# %%', 'nW') - 1
        if end_line == -1 then
          end_line = vim.fn.line '$'
        end

        local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
        lines = vim.tbl_filter(function(line)
          return not line:match '^# %%'
        end, lines)

        local code = table.concat(lines, '\n')
        iron.send(vim.bo.filetype, code)
      end

      -- Function to execute the current cell and move to the next one
      local function execute_cell_and_move()
        execute_cell()
        vim.cmd [[
          if search('^# %%', 'nW') == 0
            " We're in the last cell, create a new one
            normal! G
            call append(line('.'), ['', '# %%', ''])
            normal! 3j
          else
            " Move to the next cell
            call search('^# %%', 'W')
            normal! j
          endif
        ]]
      end

      -- Function to execute the current line and move to the next line
      local function execute_line_and_move()
        local current_line = vim.api.nvim_get_current_line()
        iron.send(vim.bo.filetype, current_line)

        local last_line = vim.fn.line '$'
        local current_line_num = vim.fn.line '.'

        if current_line_num == last_line then
          -- If it's the last line, create a new line and move to it
          vim.cmd 'normal! o'
        else
          -- Otherwise, just move to the next line
          vim.cmd 'normal! j'
        end
      end

      -- Function to execute the current line without moving
      local function execute_line()
        local current_line = vim.api.nvim_get_current_line()
        iron.send(vim.bo.filetype, current_line)
      end
      -- Function to create a new cell below the current one
      local function create_cell_below()
        local current_line = vim.fn.line '.'
        vim.api.nvim_buf_set_lines(0, current_line, current_line, false, { '', '# %%', '' })
        vim.api.nvim_win_set_cursor(0, { current_line + 3, 0 })
      end

      -- New function to remove the current cell
      local function remove_current_cell()
        local current_line = vim.fn.line '.'
        local start_line = vim.fn.search('^# %%', 'bnW')
        local end_line = vim.fn.search('^# %%', 'nW') - 1

        if start_line == 0 then
          start_line = 1
        end

        if end_line == -1 then
          end_line = vim.fn.line '$'
        end

        -- Delete the cell
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})

        -- Move cursor to the start of the next cell or the end of the file
        local next_cell = vim.fn.search('^# %%', 'nW')
        if next_cell == 0 then
          vim.api.nvim_win_set_cursor(0, { vim.fn.line '$', 0 })
        else
          vim.api.nvim_win_set_cursor(0, { next_cell, 0 })
        end
      end

      iron.setup {
        config = {
          visibility = require('iron.visibility').toggle,
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { 'zsh' },
            },
            python = fts.python.ipython,
          },
          repl_open_cmd = custom_repl_open_cmd,
        },
        keymaps = {
          send_file = '<space>ja',
          send_line = '<space>jl',
          send_until_cursor = '<space>jc',
          exit = '<space>jq',
          visual_send = '<space>jv',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }

      -- Create user commands
      vim.api.nvim_create_user_command('IronExecuteCell', execute_cell, {})
      vim.api.nvim_create_user_command('IronExecuteAndMove', execute_cell_and_move, {})
      vim.api.nvim_create_user_command('IronExecuteLineAndMove', execute_line_and_move, {})
      vim.api.nvim_create_user_command('IronExecuteLine', execute_line, {})
      vim.api.nvim_create_user_command('IronCreateCellBelow', create_cell_below, {})
      vim.api.nvim_create_user_command('IronRemoveCurrentCell', remove_current_cell, {})

      -- Set up the toggle keymap
      vim.keymap.set('n', '<space>jj', function()
        iron.repl_for(vim.bo.filetype)
      end, { noremap = true, silent = true, desc = 'Toggle REPL' })

      -- Set up a keymap to execute the current cell (m for 'mark')
      vim.keymap.set('n', '<space>jm', execute_cell, { noremap = true, silent = true, desc = 'Execute current cell' })

      -- Set up a keymap to execute the current cell and move to the next one (n for 'next')
      vim.keymap.set('n', '<space>jn', execute_cell_and_move, { noremap = true, silent = true, desc = 'Execute current cell and move to next' })

      -- Set up a keymap to execute the current line and move to the next line
      vim.keymap.set('n', '<space>jl', execute_line_and_move, { noremap = true, silent = true, desc = 'Execute current line and move to next' })

      -- Set up a keymap to execute the current line without moving
      vim.keymap.set('n', '<space>je', execute_line, { noremap = true, silent = true, desc = 'Execute current line' })
      vim.keymap.set('n', '<space>jc', create_cell_below, { noremap = true, silent = true, desc = 'Create cell below' })
      vim.keymap.set('n', '<space>jd', remove_current_cell, { noremap = true, silent = true, desc = 'Remove current cell' })

      -- Additional setup for better REPL experience
      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*',
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.cmd 'startinsert'
          vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = true, noremap = true, silent = true })
        end,
      })

      -- Set ttimeoutlen to 0 to eliminate delay when pressing Esc
      vim.opt.ttimeoutlen = 0

      -- Add custom keymaps for REPL buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'iron',
        callback = function()
          vim.keymap.set('i', 'jk', '<Esc>', { buffer = true, noremap = true, silent = true })
          vim.keymap.set('n', 'i', 'i', { buffer = true, noremap = true, silent = true })
        end,
      })

      -- Add keymap to easily focus out of REPL
      vim.keymap.set('n', '<leader>wo', '<C-w>p', { noremap = true, silent = true, desc = 'Go to previous (last accessed) window' })
    end,
  },
}
