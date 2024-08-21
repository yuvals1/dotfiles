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

        -- Add Esc mapping for the REPL buffer
        vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

        return win
      end

      -- Custom function to toggle REPL
      local function toggle_repl()
        local ft = vim.bo.filetype
        if ft == '' then
          print 'No filetype detected'
          return
        end
        iron.repl_for(ft)
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
          -- send_motion = '<space>re',
          visual_send = '<space>jm',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }

      -- Set up the toggle keymap outside of iron.setup
      vim.api.nvim_set_keymap(
        'n',
        '<space>jj',
        [[<cmd>lua require('iron.core').repl_for(vim.bo.filetype)<CR>]],
        { noremap = true, silent = true, desc = 'Toggle REPL' }
      )

      -- Additional setup for better REPL experience
      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*',
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.cmd 'startinsert'
          vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
        end,
      })

      -- Set ttimeoutlen to 0 to eliminate delay when pressing Esc
      vim.opt.ttimeoutlen = 0

      -- Add custom keymaps for REPL buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'iron',
        callback = function()
          -- Exit insert mode with jk
          vim.api.nvim_buf_set_keymap(0, 'i', 'jk', '<Esc>', { noremap = true, silent = true })
          -- Enter insert mode with i
          vim.api.nvim_buf_set_keymap(0, 'n', 'i', 'i', { noremap = true, silent = true })
        end,
      })

      -- Add keymap to easily focus out of REPL
      vim.keymap.set('n', '<leader>wo', '<C-w>p', { noremap = true, silent = true, desc = 'Go to previous (last accessed) window' })
    end,
  },
}
