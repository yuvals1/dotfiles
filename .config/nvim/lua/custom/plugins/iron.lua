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
          send_file = '<space>rt',
          send_line = '<space>rl',
          send_until_cursor = '<space>rc',
          exit = '<space>rq',
          send_motion = '<space>re',
          visual_send = '<space>rv',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }

      -- Set up the toggle keymap outside of iron.setup
      vim.api.nvim_set_keymap('n', '<space>ts', [[<cmd>lua require('iron.core').repl_for(vim.bo.filetype)<CR>]], { noremap = true, silent = true })
    end,
  },
}
