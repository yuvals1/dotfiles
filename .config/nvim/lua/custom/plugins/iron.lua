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
          visual_send = '<space>jm',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }

      -- Set up the toggle keymap
      vim.keymap.set('n', '<space>jj', function()
        iron.repl_for(vim.bo.filetype)
      end, { noremap = true, silent = true, desc = 'Toggle REPL' })

      -- Set up a keymap to execute the current cell
      vim.keymap.set('n', '<space>jx', execute_cell, { noremap = true, silent = true, desc = 'Execute current cell' })

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
