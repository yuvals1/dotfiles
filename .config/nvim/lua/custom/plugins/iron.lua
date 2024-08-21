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
        -- Calculate 40% of the total columns
        local width = math.floor(vim.o.columns * 0.4)
        -- Open a new vertical split on the far right
        vim.cmd('botright vertical ' .. width .. 'split')
        -- Set the buffer for this new window to the REPL buffer
        vim.api.nvim_win_set_buf(0, bufnr)
        -- Set some window options
        local win = vim.api.nvim_get_current_win()
        -- Use vim.wo instead of nvim_win_set_option
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        -- Return the window ID
        return win
      end

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { 'zsh' },
            },
            python = fts.python.ipython,
          },
          -- Use our custom function to open the REPL
          repl_open_cmd = custom_repl_open_cmd,
        },
        keymaps = {
          send_file = '<space>rt',
          send_line = '<space>rl',
          send_until_cursor = '<space>rc',
          exit = '<space>rq',
          send_motion = '<space>re',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      }
    end,
  },
}
